// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Errors that can occur during licensing operations.
public enum LicenseError: LocalizedError, Equatable {
    /// Invalid license key provided.
    case invalidLicenseKey

    /// Network error occurred during license validation.
    case networkError(Error)

    /// License validation failed on the server.
    case validationFailed

    /// Trial has already been started.
    case trialAlreadyStarted

    /// Trial has already been used on this device.
    case trialAlreadyUsed

    /// License is expired or inactive.
    case licenseExpired

    public var errorDescription: String? {
        switch self {
        case .invalidLicenseKey:
            "The license key provided is invalid."

        case let .networkError(error):
            "Network error: \(error.localizedDescription)"

        case .validationFailed:
            "License validation failed."

        case .trialAlreadyStarted:
            "Trial period has already been started."

        case .trialAlreadyUsed:
            "Trial has already been used on this device. Please purchase a license to continue using the app."

        case .licenseExpired:
            "License is expired or inactive."
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.invalidLicenseKey, .invalidLicenseKey),
             (.validationFailed, .validationFailed),
             (.trialAlreadyStarted, .trialAlreadyStarted),
             (.trialAlreadyUsed, .trialAlreadyUsed),
             (.licenseExpired, .licenseExpired):
            true

        case (.networkError, .networkError):
            // Network errors are considered equal based on case, not content
            // since Error doesn't conform to Equatable
            true

        default:
            false
        }
    }
}
