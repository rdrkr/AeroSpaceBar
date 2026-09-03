// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import Foundation

/// The event types AeroSpace can broadcast over its subscription socket.
///
/// Raw values match the `_event` discriminator emitted by AeroSpace and the
/// event names accepted by the `aerospace subscribe` command. See
/// `aerospace-subscribe(1)`; available since AeroSpace 0.21.0-Beta.
public enum AeroSpaceEventType: String, Codable, CaseIterable, Sendable {
    /// Fired when window focus changes.
    case focusChanged = "focus-changed"

    /// Fired when the focused monitor changes.
    case focusedMonitorChanged = "focused-monitor-changed"

    /// Fired when the focused workspace changes.
    case focusedWorkspaceChanged = "focused-workspace-changed"

    /// Fired when the binding mode changes.
    case modeChanged = "mode-changed"

    /// Fired when a new window is detected.
    case windowDetected = "window-detected"

    /// Fired when a keyboard binding is triggered.
    case bindingTriggered = "binding-triggered"
}

/// A decoded event received from AeroSpace's subscription socket.
///
/// AeroSpace omits `nil` fields when encoding, so every field that the server
/// declares optional is modelled as an optional here. Required fields are
/// non-optional and a payload missing one fails to decode.
public enum AeroSpaceEvent: Sendable, Equatable {
    /// Window focus changed. `windowId` is absent when no window is focused.
    case focusChanged(windowId: UInt32?, workspace: String)

    /// The focused monitor changed. `monitorId` is 1-based, or `0` when unknown.
    case focusedMonitorChanged(workspace: String, monitorId: Int)

    /// The focused workspace changed.
    ///
    /// On the initial-state burst sent at connect time, `previousWorkspace`
    /// equals `workspace`.
    case focusedWorkspaceChanged(workspace: String, previousWorkspace: String)

    /// The binding mode changed. `mode` is absent when no mode is active.
    case modeChanged(mode: String?)

    /// A new window was detected.
    case windowDetected(windowId: UInt32, workspace: String?, appBundleId: String?, appName: String?)

    /// A keyboard binding was triggered.
    case bindingTriggered(mode: String, binding: String)

    /// The type discriminator for this event.
    public var type: AeroSpaceEventType {
        switch self {
        case .focusChanged: .focusChanged
        case .focusedMonitorChanged: .focusedMonitorChanged
        case .focusedWorkspaceChanged: .focusedWorkspaceChanged
        case .modeChanged: .modeChanged
        case .windowDetected: .windowDetected
        case .bindingTriggered: .bindingTriggered
        }
    }

    /// Whether this event can change the spaces-and-windows model and therefore
    /// warrants refreshing spaces data.
    ///
    /// Binding and mode changes affect only AeroSpace's input handling, never
    /// the set of spaces or their windows, so they are ignored.
    public var requiresSpacesRefresh: Bool {
        switch self {
        case .focusChanged,
             .focusedMonitorChanged,
             .focusedWorkspaceChanged,
             .windowDetected:
            true

        case .modeChanged,
             .bindingTriggered:
            false
        }
    }

    /// Decodes a single event frame received from AeroSpace.
    ///
    /// Unknown `_event` values decode to `nil` rather than throwing, so that a
    /// future AeroSpace release adding an event type does not break the stream.
    /// - Parameters:
    ///   - data: The raw UTF-8 JSON payload of one frame
    ///   - decoder: The decoder to use
    /// - Returns: The decoded event, or `nil` if the event type is unrecognised
    /// - Throws: `AppError.decodingError` if the payload is malformed or a
    ///   required field for a known event type is missing
    public static func decode(from data: Data, using decoder: JSONDecoder = JSONDecoder()) throws -> Self? {
        let payload: AeroSpaceEventPayload
        do {
            payload = try decoder.decode(AeroSpaceEventPayload.self, from: data)
        } catch {
            throw AppError.decodingError(error.localizedDescription)
        }

        guard let type = AeroSpaceEventType(rawValue: payload.event) else {
            Logger.debug(
                "Ignoring unrecognised AeroSpace event type",
                category: Logger.aerospace,
                metadata: ["event": payload.event]
            )
            return nil
        }

        return try make(type: type, payload: payload)
    }

    /// Builds an event of the given type from a decoded payload.
    /// - Parameters:
    ///   - type: The event type discriminator
    ///   - payload: The decoded wire payload
    /// - Returns: The corresponding event
    /// - Throws: `AppError.decodingError` if a field required by `type` is absent
    private static func make(type: AeroSpaceEventType, payload: AeroSpaceEventPayload) throws -> Self {
        switch type {
        case .focusChanged:
            try .focusChanged(
                windowId: payload.windowId,
                workspace: require(payload.workspace, field: "workspace", type: type)
            )

        case .focusedMonitorChanged:
            try .focusedMonitorChanged(
                workspace: require(payload.workspace, field: "workspace", type: type),
                monitorId: require(payload.monitorId, field: "monitorId", type: type)
            )

        case .focusedWorkspaceChanged:
            try .focusedWorkspaceChanged(
                workspace: require(payload.workspace, field: "workspace", type: type),
                previousWorkspace: require(payload.prevWorkspace, field: "prevWorkspace", type: type)
            )

        case .modeChanged:
            .modeChanged(mode: payload.mode)

        case .windowDetected:
            try .windowDetected(
                windowId: require(payload.windowId, field: "windowId", type: type),
                workspace: payload.workspace,
                appBundleId: payload.appBundleId,
                appName: payload.appName
            )

        case .bindingTriggered:
            try .bindingTriggered(
                mode: require(payload.mode, field: "mode", type: type),
                binding: require(payload.binding, field: "binding", type: type)
            )
        }
    }

    /// Unwraps a field that the given event type requires.
    /// - Parameters:
    ///   - value: The decoded optional value
    ///   - field: The wire field name, used in the error message
    ///   - type: The event type being decoded, used in the error message
    /// - Returns: The unwrapped value
    /// - Throws: `AppError.decodingError` if `value` is `nil`
    private static func require<T>(_ value: T?, field: String, type: AeroSpaceEventType) throws -> T {
        guard let value else {
            throw AppError.decodingError("Missing '\(field)' in '\(type.rawValue)' event")
        }

        return value
    }
}

/// The wire representation of an AeroSpace server event.
///
/// Mirrors `ServerEvent` in the AeroSpace sources: a flat object whose
/// `_event` field discriminates the payload and whose remaining fields are
/// present only when relevant and non-`nil`.
private struct AeroSpaceEventPayload: Decodable {
    let event: String
    let windowId: UInt32?
    let workspace: String?
    let prevWorkspace: String?
    let monitorId: Int?
    let appBundleId: String?
    let appName: String?
    let mode: String?
    let binding: String?

    private enum CodingKeys: String, CodingKey {
        case event = "_event"
        case windowId
        case workspace
        case prevWorkspace
        case monitorId
        case appBundleId
        case appName
        case mode
        case binding
    }
}
