// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import Foundation

/// Test fixtures for License entities.
///
/// This provides reusable, well-defined test data for License testing
/// to ensure consistent and predictable testing.
public enum LicenseFixtures {
    // MARK: - License Keys

    public static let validPurchasedKey = "ABC123-DEF456-GHI789-PURCHASED" // gitleaks:allow
    public static let validTrialKey = "XYZ789-UVW456-RST123-TRIAL" // gitleaks:allow
    public static let invalidKey = "INVALID-KEY"
    public static let expiredKey = "EXPIRED-LICENSE-KEY"

    // MARK: - License Info Fixtures

    /// Unknown license status (no license)
    public static let unknown = LicenseInfo(
        licenseKey: "",
        licenseStatus: .unknown,
        userName: "",
        email: ""
    )

    /// Fully licensed with purchased license
    public static let licensed = LicenseInfo(
        licenseKey: validPurchasedKey,
        licenseStatus: .licensed,
        userName: "John Doe",
        email: "john.doe@example.com"
    )

    /// Licensed with profile image
    public static let licensedWithProfile = LicenseInfo(
        licenseKey: validPurchasedKey,
        licenseStatus: .licensed,
        userName: "Jane Smith",
        email: "jane.smith@example.com",
        profileImageData: Data("MOCK_IMAGE_DATA".utf8)
    )

    /// Active trial with 10 days remaining
    public static let trial10Days = LicenseInfo(
        licenseKey: validTrialKey,
        licenseStatus: .trial(daysRemaining: 10),
        userName: "Trial User",
        email: "trial@example.com"
    )

    /// Active trial with 3 days remaining (near expiration)
    public static let trial3Days = LicenseInfo(
        licenseKey: validTrialKey,
        licenseStatus: .trial(daysRemaining: 3),
        userName: "Trial User",
        email: "trial@example.com"
    )

    /// Active trial with 1 day remaining
    public static let trial1Day = LicenseInfo(
        licenseKey: validTrialKey,
        licenseStatus: .trial(daysRemaining: 1),
        userName: "Trial User",
        email: "trial@example.com"
    )

    /// Expired license (was a trial)
    public static let expiredTrial = LicenseInfo(
        licenseKey: expiredKey,
        licenseStatus: .expired,
        userName: "Expired User",
        email: "expired@example.com"
    )

    /// License being validated
    public static let validating = LicenseInfo(
        licenseKey: validPurchasedKey,
        licenseStatus: .validating,
        userName: "Validating User",
        email: "validating@example.com"
    )

    // MARK: - Test Scenarios for License Bug Fix

    /// Purchased license that was incorrectly marked as expired
    /// This tests the fix for the trial expiration bug
    public static let purchasedButExpiredByMistake = LicenseInfo(
        licenseKey: validPurchasedKey,
        licenseStatus: .expired, // This should NEVER happen for purchased licenses
        userName: "Bug Victim",
        email: "bug@example.com"
    )

    // MARK: - Builder Methods

    /// Creates a licensed LicenseInfo with custom details
    public static func licensed(
        key: String = validPurchasedKey,
        userName: String = "Test User",
        email: String = "test@example.com"
    ) -> LicenseInfo {
        LicenseInfo(
            licenseKey: key,
            licenseStatus: .licensed,
            userName: userName,
            email: email
        )
    }

    /// Creates a trial LicenseInfo with specific days remaining
    public static func trial(
        daysRemaining: Int,
        key: String = validTrialKey,
        userName: String = "Trial User",
        email: String = "trial@example.com"
    ) -> LicenseInfo {
        LicenseInfo(
            licenseKey: key,
            licenseStatus: .trial(daysRemaining: daysRemaining),
            userName: userName,
            email: email
        )
    }

    /// Creates an expired LicenseInfo
    public static func expired(
        key: String = expiredKey,
        userName: String = "Expired User",
        email: String = "expired@example.com"
    ) -> LicenseInfo {
        LicenseInfo(
            licenseKey: key,
            licenseStatus: .expired,
            userName: userName,
            email: email
        )
    }
}
