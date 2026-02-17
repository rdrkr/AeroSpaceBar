// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

enum TimeoutState<ResultType: Sendable>: Sendable {
    case operationResult(Result<ResultType, Error>)
    case sleepResult(Result<Bool, Error>)
}

/// An error indicating that the withTimeout has passed and the operation did not complete.
public struct TimeoutExceededError: Error {
    public init() { }
}

/// Race the given operation against a withTimeout.
///
/// This function provides a mechanism for enforcing timeouts on asynchronous operations that lack native withTimeout
/// support. It creates a `TaskGroup` with two concurrent tasks: the provided operation and a sleep task.
///
/// - Parameters:
///   - instant: The absolute withTimeout for the operation to complete.
///   - tolerance: The allowed tolerance for the withTimeout.
///   - clock: The clock used for timing the operation.
///   - isolation: The isolation passed on to the task group.
///   - operation: The asynchronous operation to be executed.
///
/// - Returns: The result of the operation if it completes before the withTimeout.
/// - Throws: `TimeoutExceededError`, if the operation fails to complete before the withTimeout and errors thrown by
/// the
/// operation or clock.
///
/// ## Example
/// ```swift
/// let result = try await withTimeout(until: .now + .seconds(5)) {
///   try await Task.sleep(for: .seconds(1))
///   return "success"
/// }
/// ```
///
/// - Important: The operation closure must support cooperative cancellation. Otherwise, the withTimeout will not be
/// respected.
public func withTimeout<ClockType: Clock, ResultType: Sendable>(
    until instant: ClockType.Instant,
    tolerance: ClockType.Instant.Duration? = nil,
    clock: ClockType,
    isolation: isolated (any Actor)? = #isolation,
    operation: @Sendable () async throws -> ResultType
) async throws -> ResultType {
    // NB: This is safe to use, because the closure will not escape the context of this function.
    let result = await withoutActuallyEscaping(operation) { operation in
        await withTaskGroup(
            of: TimeoutState<ResultType>.self,
            returning: Result<ResultType, any Error>.self,
            isolation: isolation
        ) { taskGroup in
            taskGroup.addTask {
                do {
                    let result = try await operation()
                    return .operationResult(.success(result))
                } catch {
                    return .operationResult(.failure(error))
                }
            }

            taskGroup.addTask {
                do {
                    try await Task.sleep(until: instant, tolerance: tolerance, clock: clock)
                    return .sleepResult(.success(false))
                } catch where Task.isCancelled {
                    return .sleepResult(.success(true))
                } catch {
                    return .sleepResult(.failure(error))
                }
            }

            defer {
                taskGroup.cancelAll()
            }

            for await next in taskGroup {
                switch next {
                case let .operationResult(result):
                    return result

                case .sleepResult(.success(false)):
                    return .failure(TimeoutExceededError())

                case .sleepResult(.success(true)):
                    continue

                case let .sleepResult(.failure(error)):
                    return .failure(error)
                }
            }

            preconditionFailure("Invalid state")
        }
    }

    return try result.get()
}

/// Race the given operation against a withTimeout.
///
/// This function provides a mechanism for enforcing timeouts on asynchronous operations that lack native withTimeout
/// support. It creates a `TaskGroup` with two concurrent tasks: the provided operation and a sleep task.
/// `ContinuousClock` will be used as the default clock.
///
/// - Parameters:
///   - instant: The absolute withTimeout for the operation to complete.
///   - tolerance: The allowed tolerance for the withTimeout.
///   - isolation: The isolation passed on to the task group.
///   - operation: The asynchronous operation to be executed.
///
/// - Returns: The result of the operation if it completes before the withTimeout.
/// - Throws: `TimeoutExceededError`, if the operation fails to complete before the withTimeout and errors thrown by
/// the
/// operation or clock.
///
/// ## Example
/// ```swift
/// let result = try await withTimeout(until: .now + .seconds(5)) {
///   try await Task.sleep(for: .seconds(1))
///   return "success"
/// }
/// ```
///
/// - Important: The operation closure must support cooperative cancellation. Otherwise, the withTimeout will not be
/// respected.
public func withTimeout<ResultType: Sendable>(
    until instant: ContinuousClock.Instant,
    tolerance: ContinuousClock.Instant.Duration? = nil,
    isolation: isolated (any Actor)? = #isolation,
    operation: @Sendable () async throws -> ResultType
) async throws -> ResultType {
    try await withTimeout(
        until: instant,
        tolerance: tolerance,
        clock: ContinuousClock(),
        isolation: isolation,
        operation: operation
    )
}

/// Race the given operation against a timeout duration.
///
/// This function provides a mechanism for enforcing timeouts on asynchronous operations that lack native withTimeout
/// support. It creates a `TaskGroup` with two concurrent tasks: the provided operation and a sleep task.
///
/// - Parameters:
///   - duration: The duration to wait before timing out.
///   - tolerance: The allowed tolerance for the timeout.
///   - clock: The clock used for timing the operation.
///   - isolation: The isolation passed on to the task group.
///   - operation: The asynchronous operation to be executed.
///
/// - Returns: The result of the operation if it completes before the timeout.
/// - Throws: `TimeoutExceededError`, if the operation fails to complete before the timeout and errors thrown by the
/// operation or clock.
///
/// ## Example
/// ```swift
/// let result = try await withTimeout(for: .seconds(5)) {
///   try await Task.sleep(for: .seconds(1))
///   return "success"
/// }
/// ```
///
/// - Important: The operation closure must support cooperative cancellation. Otherwise, the timeout will not be
/// respected.
public func withTimeout<ClockType: Clock, ResultType: Sendable>(
    for duration: ClockType.Instant.Duration,
    tolerance: ClockType.Instant.Duration? = nil,
    clock: ClockType,
    isolation: isolated (any Actor)? = #isolation,
    operation: @Sendable () async throws -> ResultType
) async throws -> ResultType {
    try await withTimeout(
        until: clock.now.advanced(by: duration),
        tolerance: tolerance,
        clock: clock,
        isolation: isolation,
        operation: operation
    )
}

/// Race the given operation against a timeout duration.
///
/// This function provides a mechanism for enforcing timeouts on asynchronous operations that lack native withTimeout
/// support. It creates a `TaskGroup` with two concurrent tasks: the provided operation and a sleep task.
/// `ContinuousClock` will be used as the default clock.
///
/// - Parameters:
///   - duration: The duration to wait before timing out.
///   - tolerance: The allowed tolerance for the timeout.
///   - isolation: The isolation passed on to the task group.
///   - operation: The asynchronous operation to be executed.
///
/// - Returns: The result of the operation if it completes before the timeout.
/// - Throws: `TimeoutExceededError`, if the operation fails to complete before the timeout and errors thrown by the
/// operation or clock.
///
/// ## Example
/// ```swift
/// let result = try await withTimeout(for: .seconds(5)) {
///   try await Task.sleep(for: .seconds(1))
///   return "success"
/// }
/// ```
///
/// - Important: The operation closure must support cooperative cancellation. Otherwise, the timeout will not be
/// respected.
public func withTimeout<ResultType: Sendable>(
    for duration: ContinuousClock.Instant.Duration,
    tolerance: ContinuousClock.Instant.Duration? = nil,
    isolation: isolated (any Actor)? = #isolation,
    operation: @Sendable () async throws -> ResultType
) async throws -> ResultType {
    try await withTimeout(
        for: duration,
        tolerance: tolerance,
        clock: ContinuousClock(),
        isolation: isolation,
        operation: operation
    )
}
