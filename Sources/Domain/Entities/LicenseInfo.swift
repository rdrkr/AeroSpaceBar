// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// License information from Paddle.
public struct LicenseInfo: Codable, Equatable, Sendable {
    /// The license key.
    public let licenseKey: String

    /// The current license status.
    public let licenseStatus: LicenseStatus

    /// The user's display name.
    public let userName: String

    /// The user's profile image data.
    public let profileImageData: Data?

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
        profileImageData: Data? = nil
    ) {
        self.licenseKey = licenseKey
        self.licenseStatus = licenseStatus
        self.userName = userName
        self.profileImageData = profileImageData
    }
}
