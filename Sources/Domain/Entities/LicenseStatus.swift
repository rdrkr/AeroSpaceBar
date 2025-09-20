// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

/// Represents the current license status of the application.
public enum LicenseStatus: Equatable, Sendable {
    /// The application is in trial mode with remaining days.
    case trial(daysRemaining: Int)

    /// The application is fully licensed.
    case licensed

    /// The trial has expired.
    case expired

    /// License validation is in progress.
    case validating

    /// No license information available (first launch).
    case unknown
}
