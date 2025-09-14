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
    /// The associated licensing view model.
    @EnvironmentObject private var viewModel: LicensingViewModel

    /// The window's control active state for focus-dependent styling.
    @Environment(\.controlActiveState) private var controlActiveState

    /// The user's display name from UserDefaults.
    @State private var userName: String = ""

    /// The user's profile image from UserDefaults.
    @State private var profileImage: NSImage?

    /// The body of the license settings sidebar item view.
    /// - Returns: A horizontal stack containing the profile image and user information
    var body: some View {
        HStack {
            // Profile Image
            Group {
                if let profileImage {
                    Image(nsImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
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
                Text(isLicensed ? (userName.isEmpty ? String(localized: "Set Your Name") : userName) :
                    String(localized: "License Not Activated")
                )
                .font(.headline)
                .foregroundStyle(
                    controlActiveState == .key ?
                        (isLicensed ? (userName.isEmpty ? .secondary : .primary) : .secondary) :
                        .quaternary
                )

                // Status Text
                Text(isLicensed ? String(localized: "Licensed User") :
                    String(localized: "Purchase a license to customize your profile")
                )
                .font(.subheadline)
                .foregroundStyle(controlActiveState == .key ? .secondary : .quaternary)
            }
        }
        .onAppear {
            loadProfile()
        }
        .onChange(of: viewModel.licenseStatus) { _, _ in
            loadProfile()
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            loadProfile()
        }
    }

    // MARK: - Computed Properties

    /// Whether the user has an active license.
    private var isLicensed: Bool {
        if case .licensed = viewModel.licenseStatus {
            return true
        }
        return false
    }

    // MARK: - Private Methods

    /// Loads saved profile data from UserDefaults.
    private func loadProfile() {
        userName = UserDefaults.standard.string(forKey: UserDefaultsKeys.profileUserName.rawValue) ?? ""

        if let imageData = UserDefaults.standard.data(forKey: UserDefaultsKeys.profileImageData.rawValue) {
            profileImage = NSImage(data: imageData)
        } else {
            profileImage = nil
        }
    }
}
