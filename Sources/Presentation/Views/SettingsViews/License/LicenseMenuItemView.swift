// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import Service
import SwiftUI

/// Menu item view that displays licensing status and provides access to license actions.
///
/// This view presents a compact summary of the current license status in the application menu,
/// with a capsule-shaped button design that adapts to different license states. Tapping the item
/// opens the settings window and navigates directly to the license settings page.
struct LicenseMenuItemView: View {
    /// Environment action to open the settings window.
    @Environment(\.openSettings) private var openSettings

    /// Environment action to dismiss the current modal presentation.
    @Environment(\.dismiss) var dismiss

    /// The current license information containing status and metadata.
    @Binding private var licenseInfo: LicenseInfo

    /// Creates a new license menu item view.
    ///
    /// - Parameter licenseInfo: A binding to the current license information
    ///   that will be used to determine the display text and behavior.
    init(licenseInfo: Binding<LicenseInfo>) {
        _licenseInfo = licenseInfo
    }

    var body: some View {
        HStack {
            Button {
                openLicenseSettings()
            } label: {
                if let title = licenseStatusTitle {
                    Text(title)
                        .secondaryText()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .buttonBorderShape(.capsule)
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
    }

    // MARK: - Actions

    /// Opens the settings window and navigates to the license page.
    ///
    /// This method performs a coordinated action to both open the settings window
    /// and ensure that the license page is displayed when the window appears.
    /// It uses a notification-based approach to communicate the navigation intent
    /// to the settings view.
    ///
    /// ## Process
    /// 1. Posts a notification to trigger license page navigation
    /// 2. Waits briefly to ensure the notification is processed
    /// 3. Opens the settings window using the environment action
    ///
    /// - Note: The small delay ensures proper coordination between the notification
    ///         and the settings window opening sequence.
    private func openLicenseSettings() {
        Task {
            // Post notification to navigate to license page when settings opens
            NotificationCenter.default.post(name: .navigateToLicensePage, object: nil)
            try await Task.sleep(for: .milliseconds(60))
            openSettings()
            dismiss()
        }
    }

    // MARK: - Computed Properties

    /// Returns a localized title string for the current license status.
    private var licenseStatusTitle: LocalizedStringResource? {
        switch licenseInfo.licenseStatus {
        case let .trial(daysRemaining):
            "Trial - \(daysRemaining) days left"
        case .expired:
            "Trial Expired - Purchase to continue"
        case .unknown:
            "Start Trial"
        default:
            nil
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// Notification sent when the license settings should be opened.
    static let navigateToLicensePage = Notification.Name("navigateToLicensePage")
}
