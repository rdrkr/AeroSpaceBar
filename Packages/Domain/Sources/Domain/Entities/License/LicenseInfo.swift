// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// License information.
public struct LicenseInfo: Codable, Equatable, Sendable {
    /// The license key.
    public var licenseKey: String

    /// The current license status.
    public var licenseStatus: LicenseStatus

    /// The user's display name.
    public var userName: String

    /// The user's email address.
    public var email: String

    /// The user's profile image data.
    public var profileImageData: Data?

    /// Whether the license is active.
    public var isActive: Bool {
        switch licenseStatus {
        case .licensed,
             .trial:
            true

        case .expired,
             .validating,
             .unknown:
            false
        }
    }

    public init(
        licenseKey: String = "",
        licenseStatus: LicenseStatus = .unknown,
        userName: String = "",
        email: String = "",
        profileImageData: Data? = nil
    ) {
        self.licenseKey = licenseKey
        self.licenseStatus = licenseStatus
        self.userName = userName
        self.email = email
        self.profileImageData = profileImageData
    }
}
