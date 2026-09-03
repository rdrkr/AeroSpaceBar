// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Domain
import Foundation
import SwiftUI

/// A view that displays the license settings sidebar item with custom layout.
///
/// This view provides a specialized sidebar representation for the license settings page,
/// displaying the user's profile image alongside their information in a compact layout.
struct LicenseSettingsSidebarItemView: View {
    /// The associated license view model.
    @EnvironmentObject private var viewModel: LicenseViewModel

    /// The window's control active state for focus-dependent styling.
    @Environment(\.controlActiveState) private var controlActiveState

    /// The body of the license settings sidebar item view.
    /// - Returns: A horizontal stack containing the profile image and user information
    var body: some View {
        HStack(spacing: 8) {
            // Profile Image
            Group {
                if let profileImage = viewModel.profileImage {
                    Image(nsImage: profileImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundStyle(controlActiveState == .key ? .secondary : .quaternary)
                }
            }
            .frame(width: 38, height: 38)
            .clipShape(Circle())
            .opacity(controlActiveState == .key ? 1.0 : 0.5)

            // User Info
            VStack(alignment: .leading, spacing: 2) {
                // User Name
                Text(isLicensed ?
                    (viewModel.licenseInfo.userName.isEmpty ? String(localized: "Set Your Name") : viewModel.licenseInfo
                        .userName
                    ) :
                    String(localized: "License Not Activated")
                )
                .font(.headline)
                .foregroundStyle(
                    controlActiveState == .key ?
                        (isLicensed ? (viewModel.licenseInfo.userName.isEmpty ? .secondary : .primary) : .secondary) :
                        .quaternary
                )

                // Status Text
                Text(isLicensed ?
                    (!viewModel.licenseInfo.email.isEmpty ? viewModel.licenseInfo
                        .email : String(localized: "Licensed User")) :
                    String(localized: "Purchase a license to customize your profile")
                )
                .font(.subheadline)
                .foregroundStyle(controlActiveState == .key ? .secondary : .quaternary)
            }
        }
        .animation(.themeEaseInOutFast, value: isLicensed)
        .animation(.themeEaseInOutFast, value: viewModel.licenseInfo.userName)
        .animation(.themeEaseInOutFast, value: viewModel.licenseInfo.email)
        .animation(.themeEaseInOutFast, value: viewModel.profileImage)
        .animation(.themeEaseInOutFast, value: controlActiveState)
    }

    // MARK: - Computed Properties

    /// Whether the user has an active license.
    private var isLicensed: Bool {
        viewModel.isLicensed
    }
}
