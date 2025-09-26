// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the user's display name.
///
/// This use case allows updating the user's display name in the license information.
@MainActor
public final class SetUserNameUseCase {
    /// The license gateway for license operations.
    private let licenseGateway: LicenseGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licenseGateway: The gateway for license operations
    public init(licenseGateway: LicenseGateway) {
        self.licenseGateway = licenseGateway
    }

    /// Sets the user's display name.
    /// - Parameter userName: The user's display name to set
    public func execute(userName: String) async {
        await licenseGateway.setUserName(userName)
    }
}
