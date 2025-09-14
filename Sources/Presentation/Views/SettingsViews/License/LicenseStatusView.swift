// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import Service
import SwiftUI

/// View that displays the current license status and provides licensing actions.
///
/// This view presents a comprehensive license status interface including:
/// - Large status icon and title
/// - Detailed status description
/// - Contextual action buttons (trial, purchase, activation)
/// - License key input and activation interface
struct LicenseStatusView: View {
    /// The licensing view model that provides license status and actions.
    @ObservedObject var viewModel: LicensingViewModel

    /// Environment dismiss action for closing the view.
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: licenseStatusIcon)
                    .font(.system(size: 48))
                    .foregroundStyle(licenseStatusColor)

                Text(licenseStatusTitle)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(licenseStatusDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top)

            Divider()

            // Actions
            VStack(spacing: 12) {
                switch viewModel.licenseStatus {
                case .unknown,
                     .trial,
                     .expired:
                    purchaseButtons

                case .licensed:
                    licensedInfo

                case .validating:
                    ProgressView(LocalizedStringResource("Validating license..."))
                        .frame(maxWidth: .infinity)

                @unknown default:
                    purchaseButtons
                }
            }

            Divider()

            // License key input (always available)
            licenseKeyInput
        }
        .padding()
        .frame(width: 400)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Computed Properties

    /// Returns the appropriate SF Symbol icon name for the current license status.
    private var licenseStatusIcon: String {
        switch viewModel.licenseStatus {
        case .licensed:
            "checkmark.shield.fill"
        case .trial:
            "clock.badge.checkmark"
        case .expired:
            "exclamationmark.shield.fill"
        case .validating:
            "hourglass"
        case .unknown:
            "questionmark.circle"
        @unknown default:
            "questionmark.circle"
        }
    }

    /// Returns the appropriate color for the current license status.
    private var licenseStatusColor: Color {
        switch viewModel.licenseStatus {
        case .licensed:
            .green
        case .trial:
            .blue
        case .expired:
            .red
        case .validating:
            .orange
        case .unknown:
            .gray
        @unknown default:
            .gray
        }
    }

    /// Returns a localized title string for the current license status.
    private var licenseStatusTitle: LocalizedStringResource {
        switch viewModel.licenseStatus {
        case .licensed:
            "Licensed"
        case let .trial(daysRemaining):
            "Trial (\(daysRemaining) days left)"
        case .expired:
            "License Expired"
        case .validating:
            "Validating..."
        case .unknown:
            "Welcome to AeroSpaceBar"
        @unknown default:
            "Unknown Status"
        }
    }

    /// Returns a comprehensive localized description for the current license status.
    private var licenseStatusDescription: LocalizedStringResource {
        switch viewModel.licenseStatus {
        case .licensed:
            "Thank you for supporting AeroSpaceBar! You have full access to all features."

        case let .trial(daysRemaining):
            if daysRemaining <= 3 {
                "Your trial expires soon. Purchase a license to continue using AeroSpaceBar."
            } else {
                "You're using the trial version. All features are available during the trial period."
            }

        case .expired:
            "Your trial has expired. Please purchase a license to continue using AeroSpaceBar."

        case .validating:
            "Checking license status with our servers..."

        case .unknown:
            "Start your free 14-day trial or enter your license key if you've already purchased."

        @unknown default:
            "Unknown license status. Please try again or contact support."
        }
    }

    // MARK: - View Components

    /// View containing purchase and trial action buttons.
    private var purchaseButtons: some View {
        VStack(spacing: 8) {
            Button(LocalizedStringResource("Start Free Trial")) {
                viewModel.startTrial()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.licenseStatus.isTrialStarted)

            Button(LocalizedStringResource("Purchase License")) {
                viewModel.openCheckout()
            }
            .buttonStyle(.bordered)

            if case .trial = viewModel.licenseStatus {
                Text(LocalizedStringResource("Trial started. You can purchase a license anytime during the trial."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// View containing license information for licensed users.
    private var licensedInfo: some View {
        VStack(spacing: 8) {
            HStack {
                Text(LocalizedStringResource("License Key:"))
                    .fontWeight(.medium)
                Spacer()
                Text(viewModel.maskedLicenseKey ?? String(localized: "Unknown"))
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Button(LocalizedStringResource("Deactivate License")) {
                viewModel.deactivateLicense()
            }
            .buttonStyle(.bordered)
            .foregroundStyle(.red)
        }
    }

    /// View containing the license key input and activation interface.
    private var licenseKeyInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringResource("Have a license key?"))
                .font(.headline)

            HStack {
                TextField(text: $viewModel.licenseKeyInput) {
                    Text(LocalizedStringResource("Enter your license key"))
                }
                .textFieldStyle(.roundedBorder)

                Button(LocalizedStringResource("Activate")) {
                    viewModel.activateLicense()
                }
                .disabled(viewModel.licenseKeyInput.isEmpty || viewModel.isActivating)

                if viewModel.isActivating {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            if let error = viewModel.activationError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

// MARK: - License Status Extensions

/// Extension providing utility computed properties for LicenseStatus.
private extension LicenseStatus {
    /// Returns true if a trial period has been started (includes trial, licensed, and expired states).
    var isTrialStarted: Bool {
        switch self {
        case .trial,
             .licensed,
             .expired:
            true
        case .unknown,
             .validating:
            false
        @unknown default:
            false
        }
    }
}

// MARK: - Preview

#Preview {
    let gateway = LicensingRepository()
    let featureFlagsGateway = FeatureFlagsRepository()
    LicenseStatusView(viewModel: LicensingViewModel(
        getLicenseStatusUseCase: GetLicenseStatusUseCase(licensingGateway: gateway),
        activateLicenseUseCase: ActivateLicenseUseCase(licensingGateway: gateway),
        openCheckoutUseCase: OpenCheckoutUseCase(licensingGateway: gateway),
        startTrialUseCase: StartTrialUseCase(licensingGateway: gateway),
        deactivateLicenseUseCase: DeactivateLicenseUseCase(licensingGateway: gateway),
        getFeatureFlagsUseCase: GetFeatureFlagsUseCase(gateway: featureFlagsGateway)
    ))
}
