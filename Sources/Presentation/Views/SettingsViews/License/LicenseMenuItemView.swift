// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import Service
import SwiftUI

/// Menu item view that displays licensing status and provides access to license actions.
///
/// This view presents a compact summary of the current license status in the application menu,
/// including an icon, title, and optional subtitle. Tapping the item opens the detailed
/// license status window for further actions.
struct LicenseMenuItemView: View {
    /// The licensing view model that provides license status and actions.
    @EnvironmentObject var viewModel: LicensingViewModel

    /// Whether the license status detail window is currently shown.
    @State private var showingLicenseWindow = false

    var body: some View {
        Button {
            showingLicenseWindow = true
        } label: {
            HStack {
                Image(systemName: licenseStatusIcon)
                    .foregroundStyle(licenseStatusColor)
                    .frame(width: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(licenseStatusTitle)
                        .font(.body)

                    if let subtitle = licenseStatusSubtitle {
                        Text(subtitle)
                            .font(.caption)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingLicenseWindow) {
            LicenseStatusView(viewModel: viewModel)
        }
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
            "Trial - \(daysRemaining) days left"
        case .expired:
            "Trial Expired"
        case .validating:
            "Validating License"
        case .unknown:
            "Start Trial"
        @unknown default:
            "Unknown"
        }
    }

    /// Returns a localized subtitle string for the current license status, if applicable.
    private var licenseStatusSubtitle: LocalizedStringResource? {
        switch viewModel.licenseStatus {
        case .licensed:
            "Thank you for your support!"

        case let .trial(daysRemaining):
            if daysRemaining <= 3 {
                "Purchase to continue"
            } else {
                nil
            }

        case .expired:
            "Purchase license to continue"

        case .validating:
            "Please wait..."

        case .unknown:
            "14-day free trial available"

        @unknown default:
            nil
        }
    }
}

// MARK: - Preview

#Preview {
    let gateway = LicensingRepository()
    LicenseMenuItemView()
        .environmentObject(LicensingViewModel(
            getLicenseStatusUseCase: GetLicenseStatusUseCase(licensingGateway: gateway),
            activateLicenseUseCase: ActivateLicenseUseCase(licensingGateway: gateway),
            openCheckoutUseCase: OpenCheckoutUseCase(licensingGateway: gateway),
            startTrialUseCase: StartTrialUseCase(licensingGateway: gateway),
            deactivateLicenseUseCase: DeactivateLicenseUseCase(licensingGateway: gateway),
            getFeatureFlagsUseCase: GetFeatureFlagsUseCase(gateway: FeatureFlagsRepository())
        ))
        .frame(width: 200)
}
