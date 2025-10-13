// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Errors that can occur during licensing operations.
public enum LicenseError: LocalizedError {
    /// Invalid license key provided.
    case invalidLicenseKey

    /// Network error occurred during license validation.
    case networkError(Error)

    /// License validation failed on the server.
    case validationFailed

    /// Trial has already been started.
    case trialAlreadyStarted

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

        case .licenseExpired:
            "License is expired or inactive."
        }
    }
}
