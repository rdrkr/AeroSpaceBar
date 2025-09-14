// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Domain
import SwiftUI

/// Settings view for managing license and subscription features.
///
/// This view provides controls for license activation, trial management,
/// profile management, and viewing license status within the main settings interface.
struct LicenseSettingsView: View {
    @EnvironmentObject private var licensingViewModel: LicensingViewModel

    /// The user's display name.
    @State private var userName = ""

    /// The user's profile image.
    @State private var profileImage: NSImage?

    var body: some View {
        Form {
            ProfileSection(
                isLicensed: isLicensed,
                userName: $userName,
                profileImage: $profileImage
            )

            LicenseStatusSection(
                licenseStatus: licensingViewModel.licenseStatus,
                maskedLicenseKey: licensingViewModel.maskedLicenseKey
            )

            LicenseActionsSection(
                enableLicensing: licensingViewModel.enableLicensing,
                licenseStatus: licensingViewModel.licenseStatus,
                licenseKeyInput: $licensingViewModel.licenseKeyInput,
                isActivating: licensingViewModel.isActivating,
                activationError: licensingViewModel.activationError,
                onStartTrial: {
                    licensingViewModel.startTrial()
                },
                onPurchaseLicense: {
                    licensingViewModel.openCheckout()
                },
                onActivateLicense: {
                    licensingViewModel.activateLicense()
                },
                onDeactivateLicense: {
                    licensingViewModel.deactivateLicense()
                },
                onClearActivationError: {
                    licensingViewModel.activationError = nil
                }
            )
        }
        .settingsFormStyle()
        .navigationTitle(LocalizedStringResource("License"))
        .sheet(isPresented: $licensingViewModel.showingCheckoutWebView) {
            if let checkoutURL = licensingViewModel.checkoutURL {
                NavigationStack {
                    CheckoutWebViewWrapper(url: checkoutURL) {
                        licensingViewModel.dismissCheckoutWebView()
                    }
                    .navigationTitle(LocalizedStringResource("Purchase License"))
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(LocalizedStringResource("Cancel")) {
                                licensingViewModel.dismissCheckoutWebView()
                            }
                        }
                    }
                }
                .frame(minWidth: 800, minHeight: 600)
            }
        }
        .onAppear {
            loadProfile()
        }
        .onChange(of: isLicensed) { _, newValue in
            if !newValue {
                // Clear profile data when license status changes to unlicensed
                userName = ""
                profileImage = nil
            } else {
                // Reload profile data when license becomes active
                loadProfile()
            }
        }
    }

    // MARK: - Computed Properties

    /// Returns true if the user has an active license.
    private var isLicensed: Bool {
        if case .licensed = licensingViewModel.licenseStatus {
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
        }
    }
}

#Preview {
    LicenseSettingsView()
        .environmentObject(DependencyContainer.shared.getLicensingViewModel())
}
