// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import Foundation
import Network

/// Client for AeroSpace's event-subscription socket.
///
/// Subscribing opens a dedicated connection: AeroSpace monopolises a connection
/// once it enters streaming mode, so this client is used only for events and
/// never for one-shot commands.
public protocol AeroSpaceSocketClientProtocol: Sendable {
    /// Connects to AeroSpace, subscribes to `events`, and yields each event
    /// until the connection drops.
    ///
    /// The stream finishes with an error when the connection is lost — which
    /// includes AeroSpace quitting or restarting. Callers are responsible for
    /// reconnecting; see `AeroSpaceEventMonitor`.
    /// - Parameter events: The event types to subscribe to
    /// - Returns: A stream of decoded events
    func subscribe(to events: [AeroSpaceEventType]) -> AsyncThrowingStream<AeroSpaceEvent, Error>
}

/// Default implementation of `AeroSpaceSocketClientProtocol` speaking AeroSpace's
/// documented unix-socket protocol.
///
/// The protocol, as of socket version 1, is:
/// 1. Connect to `/tmp/bobko.aerospace-<user>.sock`.
/// 2. Write the 4-byte little-endian protocol version; read the server's back.
///    Disconnect on mismatch.
/// 3. Write one length-prefixed `ClientRequest` frame whose `args` begin with
///    `"subscribe"`.
/// 4. Read an unbounded stream of length-prefixed event frames, sending nothing
///    further on the connection.
public struct AeroSpaceSocketClient: AeroSpaceSocketClientProtocol {
    /// Initializes the client.
    public init() { }

    /// Connects, subscribes, and streams events until the connection drops.
    public func subscribe(to events: [AeroSpaceEventType]) -> AsyncThrowingStream<AeroSpaceEvent, Error> {
        AsyncThrowingStream { continuation in
            let connection = AeroSpaceSocketConnection()

            let task = Task {
                do {
                    try await connection.open()
                    try await connection.performHandshake()
                    try await connection.sendSubscribeRequest(for: events)

                    while !Task.isCancelled {
                        let frame = try await connection.readFrame()
                        guard let event = decodeEvent(from: frame) else { continue }

                        continuation.yield(event)
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }

                await connection.close()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    /// Decodes one event frame, tolerating both unknown event types and
    /// individual malformed payloads.
    ///
    /// A bad payload affects only that event — the length-prefixed framing keeps
    /// the stream itself in sync — so it is logged and skipped rather than
    /// tearing down the subscription.
    /// - Parameter frame: The raw JSON payload of one frame
    /// - Returns: The decoded event, or `nil` if it should be skipped
    private func decodeEvent(from frame: Data) -> AeroSpaceEvent? {
        do {
            return try AeroSpaceEvent.decode(from: frame)
        } catch {
            Logger.warning(
                "Skipping undecodable AeroSpace event",
                category: Logger.aerospace,
                metadata: [
                    "error": error.localizedDescription,
                    "payload": String(data: frame, encoding: .utf8) ?? "<non-utf8>"
                ]
            )
            return nil
        }
    }
}

/// A single connection to the AeroSpace socket, exposing the framing primitives
/// the subscription protocol needs.
///
/// Serialized as an actor because `NWConnection` permits only one outstanding
/// receive at a time.
private actor AeroSpaceSocketConnection {
    /// The socket protocol version this client implements.
    private static let protocolVersion: UInt32 = 1

    /// Byte width of the protocol's length prefix and version handshake.
    private static let lengthPrefixSize = 4

    /// The AeroSpace bundle identifier, which prefixes the socket file name.
    private static let aeroSpaceAppId = "bobko.aerospace"

    /// The queue `NWConnection` delivers its callbacks on.
    private static let queue = DispatchQueue(label: "com.rdrkr.AeroSpaceBar.aerospace-socket")

    /// Path to the AeroSpace command socket for the current user.
    ///
    /// Mirrors `socketPath` in the AeroSpace sources.
    private static var socketPath: String {
        "/tmp/\(aeroSpaceAppId)-\(NSUserName()).sock"
    }

    /// The underlying connection, present only while open.
    private var connection: NWConnection?

    /// Opens the connection and waits until it is ready.
    /// - Throws: `AppError.aeroSpaceNotRunning` if the socket cannot be reached
    func open() async throws {
        let connection = NWConnection(to: .unix(path: Self.socketPath), using: .tcp)
        self.connection = connection

        let state = ConnectionReadiness()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            connection.stateUpdateHandler = { newState in
                let result: Result<Void, Error>? = switch newState {
                case .ready:
                    .success(())

                case let .failed(error),
                     let .waiting(error):
                    .failure(AppError.aeroSpaceNotRunning.wrapping(error))

                case .cancelled:
                    .failure(AppError.aeroSpaceNotRunning)

                case .preparing,
                     .setup:
                    nil

                @unknown default:
                    nil
                }

                guard let result else { return }

                Task {
                    guard await state.claim() else { return }

                    connection.stateUpdateHandler = nil
                    continuation.resume(with: result)
                }
            }

            connection.start(queue: Self.queue)
        }
    }

    /// Exchanges protocol versions with the server.
    ///
    /// The version is sent as raw bytes, *not* as a length-prefixed frame.
    /// - Throws: `AppError.commandExecutionError` if the server speaks a different version
    func performHandshake() async throws {
        try await send(Self.encodeUInt32(Self.protocolVersion))

        let serverVersion = try await Self.decodeUInt32(receive(exactly: Self.lengthPrefixSize))
        guard serverVersion == Self.protocolVersion else {
            throw AppError.commandExecutionError(
                "AeroSpace socket protocol mismatch (client \(Self.protocolVersion), server \(serverVersion))"
            )
        }
    }

    /// Sends the subscription request frame that puts the server into streaming mode.
    /// - Parameter events: The event types to subscribe to
    /// - Throws: `AppError` if encoding or sending fails
    func sendSubscribeRequest(for events: [AeroSpaceEventType]) async throws {
        let request = ClientRequest(arguments: ClientRequest.subscribeArguments(for: events))

        let payload: Data
        do {
            payload = try JSONEncoder().encode(request)
        } catch {
            throw AppError.commandExecutionError("Failed to encode subscribe request: \(error.localizedDescription)")
        }

        try await send(Self.encodeUInt32(UInt32(payload.count)) + payload)
    }

    /// Reads one length-prefixed frame.
    /// - Returns: The frame's JSON payload
    /// - Throws: `AppError.aeroSpaceNotRunning` if the connection closes
    func readFrame() async throws -> Data {
        let length = try await Self.decodeUInt32(receive(exactly: Self.lengthPrefixSize))
        guard length > 0 else { return Data() }

        return try await receive(exactly: Int(length))
    }

    /// Closes the connection, if open.
    func close() {
        connection?.stateUpdateHandler = nil
        connection?.cancel()
        connection = nil
    }

    // MARK: - Private Methods

    /// Sends raw bytes over the connection.
    /// - Parameter data: The bytes to send
    /// - Throws: `AppError.aeroSpaceNotRunning` if the connection is gone or the send fails
    private func send(_ data: Data) async throws {
        guard let connection else { throw AppError.aeroSpaceNotRunning }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            connection.send(content: data, completion: .contentProcessed { error in
                if let error {
                    continuation.resume(throwing: AppError.aeroSpaceNotRunning.wrapping(error))
                } else {
                    continuation.resume()
                }
            })
        }
    }

    /// Reads exactly `count` bytes, waiting for as many receives as it takes.
    /// - Parameter count: The number of bytes to read
    /// - Returns: Exactly `count` bytes
    /// - Throws: `AppError.aeroSpaceNotRunning` if the peer closes before `count` bytes arrive
    private func receive(exactly count: Int) async throws -> Data {
        guard let connection else { throw AppError.aeroSpaceNotRunning }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            connection.receive(minimumIncompleteLength: count, maximumLength: count) { content, _, isComplete, error in
                if let error {
                    continuation.resume(throwing: AppError.aeroSpaceNotRunning.wrapping(error))
                    return
                }

                guard let content, content.count == count else {
                    // `isComplete` without a full payload means the peer closed the
                    // connection — AeroSpace quitting, restarting, or dropping us.
                    _ = isComplete
                    continuation.resume(throwing: AppError.aeroSpaceNotRunning)
                    return
                }

                continuation.resume(returning: content)
            }
        }
    }

    /// Encodes a `UInt32` as four little-endian bytes.
    ///
    /// Written by hand rather than via `withUnsafeBytes` to keep the package
    /// free of unsafe constructs under `strictMemorySafety`.
    /// - Parameter value: The value to encode
    /// - Returns: Four bytes, least significant first
    private static func encodeUInt32(_ value: UInt32) -> Data {
        Data([
            UInt8(truncatingIfNeeded: value),
            UInt8(truncatingIfNeeded: value >> 8),
            UInt8(truncatingIfNeeded: value >> 16),
            UInt8(truncatingIfNeeded: value >> 24)
        ])
    }

    /// Decodes four little-endian bytes into a `UInt32`.
    /// - Parameter data: Exactly four bytes, least significant first
    /// - Returns: The decoded value, or `0` if `data` is not four bytes
    private static func decodeUInt32(_ data: Data) -> UInt32 {
        let bytes = [UInt8](data)
        guard bytes.count == lengthPrefixSize else { return 0 }

        return UInt32(bytes[0])
            | UInt32(bytes[1]) << 8
            | UInt32(bytes[2]) << 16
            | UInt32(bytes[3]) << 24
    }
}

/// Guards a `CheckedContinuation` that a state handler may reach more than once.
private actor ConnectionReadiness {
    /// Whether the continuation has already been resumed.
    private var isClaimed = false

    /// Claims the right to resume the continuation.
    /// - Returns: `true` for the first caller only
    func claim() -> Bool {
        if isClaimed {
            return false
        }

        isClaimed = true
        return true
    }
}

/// The request payload AeroSpace expects as the first frame on a connection.
///
/// Mirrors `ClientRequest` in the AeroSpace sources. `windowId` and `workspace`
/// carry the `AEROSPACE_WINDOW_ID` / `AEROSPACE_WORKSPACE` environment variables
/// for callback-invoked commands; they are always `nil` for a subscription.
private struct ClientRequest: Encodable {
    /// The CLI subcommand that enters event-streaming mode.
    private static let subscribeCommand = "subscribe"

    /// The CLI arguments, excluding the program name.
    let args: [String]

    /// Contents to feed the command as standard input.
    let stdin: String

    /// The window the command was triggered from, if any.
    let windowId: UInt32?

    /// The workspace the command was triggered from, if any.
    let workspace: String?

    /// Initializes a request carrying only arguments.
    /// - Parameter arguments: The CLI arguments to send
    init(arguments: [String]) {
        args = arguments
        stdin = ""
        windowId = nil
        workspace = nil
    }

    /// Builds the argument list subscribing to the given event types.
    ///
    /// Events are listed explicitly rather than using `--all` so that a future
    /// AeroSpace release adding an event type does not silently change what this
    /// app receives. The initial-state burst is left enabled: it is what
    /// resynchronises the app after a reconnect.
    /// - Parameter events: The event types to subscribe to
    /// - Returns: The `args` array for a `ClientRequest`
    static func subscribeArguments(for events: [AeroSpaceEventType]) -> [String] {
        [subscribeCommand] + events.map(\.rawValue)
    }
}

private extension AppError {
    /// Returns this error with an underlying failure's description attached.
    ///
    /// Keeps the app's own error taxonomy while preserving the network-level
    /// detail needed to diagnose a failed connection.
    /// - Parameter error: The underlying failure
    /// - Returns: A `commandExecutionError` describing both
    func wrapping(_ error: some Error) -> AppError {
        .commandExecutionError("\(errorDescription ?? "AeroSpace socket error"): \(error.localizedDescription)")
    }
}
