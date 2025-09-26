// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the user's profile image data.
///
/// This use case allows updating the user's profile image data in the license information.
@MainActor
public final class SetProfileImageDataUseCase {
    /// The license gateway for license operations.
    private let licenseGateway: LicenseGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licenseGateway: The gateway for license operations
    public init(licenseGateway: LicenseGateway) {
        self.licenseGateway = licenseGateway
    }

    /// Sets the user's profile image data.
    /// - Parameter profileImageData: The profile image data to set, or nil to clear
    public func execute(profileImageData: Data?) async {
        await licenseGateway.setProfileImageData(profileImageData)
    }
}
