// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Domain
import SwiftUI

/// Settings view for managing license and subscription features.
///
/// This view provides controls for license activation, trial management,
/// profile management, and viewing license status within the main settings interface.
struct LicenseSettingsView: View {
    @EnvironmentObject private var licenseViewModel: LicenseViewModel

    var body: some View {
        Form {
            ProfileSection(
                isLicensed: licenseViewModel.isLicensed,
                onSetUserName: licenseViewModel.setUserName,
                onSetProfileImage: licenseViewModel.setProfileImage,
                userName: licenseViewModel.licenseInfo.userName,
                profileImage: licenseViewModel.profileImage,
                email: licenseViewModel.licenseInfo.email
            )

            LicenseStatusSection(
                licenseStatus: licenseViewModel.licenseInfo.licenseStatus,
                licenseKey: licenseViewModel.licenseInfo.licenseKey
            )

            LicenseActionsSection(
                enableLicensing: licenseViewModel.enableLicense,
                enableTrialRequest: licenseViewModel.enableTrialRequest,
                licenseStatus: licenseViewModel.licenseInfo.licenseStatus,
                licenseKey: licenseViewModel.licenseInfo.licenseKey,
                licenseKeyInput: $licenseViewModel.licenseKeyInput,
                isActivating: licenseViewModel.isActivating,
                activationError: licenseViewModel.activationError,
                onStartTrial: licenseViewModel.startTrial,
                onPurchaseLicense: licenseViewModel.openCheckout,
                onActivateLicense: licenseViewModel.activateLicense,
                onDeactivateLicense: licenseViewModel.deactivateLicense,
                onClearActivationError: {
                    licenseViewModel.activationError = nil
                }
            )
        }
        .settingsFormStyle()
        .navigationTitle(LocalizedStringResource("License"))
        .sheet(isPresented: $licenseViewModel.showingCheckoutWebView) {
            if let checkoutURL = licenseViewModel.checkoutURL {
                NavigationStack {
                    CheckoutWebViewWrapper(
                        url: checkoutURL,
                        onDismiss: licenseViewModel.dismissCheckoutWebView,
                        onCheckoutSuccess: licenseViewModel.handleCheckoutSuccess
                    )
                    .navigationTitle(LocalizedStringResource("AeroSpaceBar"))
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(LocalizedStringResource("Cancel")) {
                                licenseViewModel.dismissCheckoutWebView()
                            }
                        }
                    }
                }
                .frame(minWidth: 800, minHeight: 600)
            }
        }
    }
}

#Preview {
    LicenseSettingsView()
        .environmentObject(DependencyContainer.shared.getLicenseViewModel())
}
