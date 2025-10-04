// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// Section with license-related actions and controls.
///
/// This section provides buttons and interfaces for license-related actions such as
/// starting a trial, purchasing a license, activating a license key, and deactivating a license.
struct LicenseActionsSection: View {
    /// Whether licensing features are enabled via feature flags.
    let enableLicensing: Bool

    /// Whether trial request functionality is enabled via feature flags.
    let enableTrialRequest: Bool

    /// The current license status.
    let licenseStatus: LicenseStatus

    /// The current license key (for display when licensed).
    let licenseKey: String

    /// The license key input text.
    @Binding var licenseKeyInput: String

    /// Whether a license activation operation is currently in progress.
    let isActivating: Bool

    /// Error message from the most recent license activation attempt, if any.
    let activationError: String?

    /// Callback invoked when the user wants to start a trial.
    let onStartTrial: () -> Void

    /// Callback invoked when the user wants to purchase a license.
    let onPurchaseLicense: () -> Void

    /// Callback invoked when the user wants to activate a license.
    let onActivateLicense: () -> Void

    /// Callback invoked when the user wants to deactivate their license.
    let onDeactivateLicense: () -> Void

    /// Callback invoked when the user wants to clear the activation error.
    let onClearActivationError: () -> Void

    var body: some View {
        if enableLicensing {
            Section(LocalizedStringResource("License Actions")) {
                VStack(spacing: 8) {
                    // Start Trial Button
                    if case .unknown = licenseStatus, enableTrialRequest {
                        Button {
                            onStartTrial()
                        } label: {
                            Label(
                                LocalizedStringResource("Start 14-Day Free Trial"),
                                systemImage: "play.circle.fill"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }

                    // Purchase License Button
                    switch licenseStatus {
                    case .trial,
                         .expired,
                         .unknown,
                         .validating:
                        Button {
                            onPurchaseLicense()
                        } label: {
                            Label(LocalizedStringResource("Purchase License"), systemImage: "creditcard.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)

                    case .licensed:
                        EmptyView()

                    @unknown default:
                        EmptyView()
                    }

                    // License Key Activation
                    LicenseKeyActivationView(
                        licenseStatus: licenseStatus,
                        licenseKey: licenseKey,
                        licenseKeyInput: $licenseKeyInput,
                        isActivating: isActivating,
                        activationError: activationError,
                        onActivate: onActivateLicense,
                        onClearError: onClearActivationError
                    )

                    // Deactivate License (for licensed users)
                    if case .licensed = licenseStatus {
                        Button {
                            onDeactivateLicense()
                        } label: {
                            Label(LocalizedStringResource("Deactivate License"), systemImage: "xmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var licenseKeyInput = ""

    return VStack(spacing: 20) {
        LicenseActionsSection(
            enableLicensing: true,
            enableTrialRequest: true,
            licenseStatus: .unknown,
            licenseKey: "",
            licenseKeyInput: $licenseKeyInput,
            isActivating: false,
            activationError: nil,
            onStartTrial: { },
            onPurchaseLicense: { },
            onActivateLicense: { },
            onDeactivateLicense: { },
            onClearActivationError: { }
        )

        LicenseActionsSection(
            enableLicensing: true,
            enableTrialRequest: true,
            licenseStatus: .licensed,
            licenseKey: "ABCD-EFGH-IJKL-MNOP",
            licenseKeyInput: $licenseKeyInput,
            isActivating: false,
            activationError: nil,
            onStartTrial: { },
            onPurchaseLicense: { },
            onActivateLicense: { },
            onDeactivateLicense: { },
            onClearActivationError: { }
        )

        LicenseActionsSection(
            enableLicensing: true,
            enableTrialRequest: true,
            licenseStatus: .trial(daysRemaining: 5),
            licenseKey: "",
            licenseKeyInput: $licenseKeyInput,
            isActivating: false,
            activationError: nil,
            onStartTrial: { },
            onPurchaseLicense: { },
            onActivateLicense: { },
            onDeactivateLicense: { },
            onClearActivationError: { }
        )
    }
    .padding()
}
