// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Application-specific error types.
///
/// This enum defines the various error conditions that can occur
/// throughout the application. It belongs to the domain layer as
/// these are business rules for error handling.
public enum AppError: LocalizedError, Equatable {
    /// AeroSpace is not currently running on the system.
    case aeroSpaceNotRunning

    /// A command execution failed with a specific error message.
    case commandExecutionError(String)

    /// Data fetching failed with a specific error message.
    case dataFetchError(String)

    /// Data decoding failed with a specific error message.
    case decodingError(String)

    /// The service is currently unavailable.
    case serviceUnavailable

    /// A localized description of the error.
    public var errorDescription: String? {
        switch self {
        case .aeroSpaceNotRunning:
            "AeroSpace is not running"

        case let .commandExecutionError(message):
            "Command execution failed: \(message)"

        case let .dataFetchError(message):
            "Data fetch failed: \(message)"

        case let .decodingError(message):
            "Data decoding failed: \(message)"

        case .serviceUnavailable:
            "Service is unavailable"
        }
    }
}
