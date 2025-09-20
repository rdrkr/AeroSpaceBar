// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// Section displaying current license status and information.
///
/// This section shows the current license status with appropriate icon, color,
/// title, and subtitle. For licensed users, it also displays the masked license key.
struct LicenseStatusSection: View {
    /// The current license status.
    let licenseStatus: LicenseStatus

    /// The masked license key for display purposes, if available.
    let maskedLicenseKey: String?

    var body: some View {
        Section {
            HStack(spacing: 12) {
                Image(systemName: licenseStatusIcon)
                    .foregroundStyle(licenseStatusColor)
                    .font(.title2)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(licenseStatusTitle)
                        .font(.body)
                        .fontWeight(.medium)

                    if let subtitle = licenseStatusSubtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Show masked license key for licensed users
                    if
                        case .licensed = licenseStatus,
                        let maskedKey = maskedLicenseKey
                    {
                        HStack {
                            Text(LocalizedStringResource("License Key:"))
                                .font(.caption)
                                .fontWeight(.medium)
                            Spacer()
                            Text(maskedKey)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 2)
                    }
                }

                Spacer()

                if case .validating = licenseStatus {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.vertical, 4)
            .animation(.themeEaseInOutFast, value: licenseStatus)
        }
    }

    // MARK: - Computed Properties

    /// Returns the appropriate SF Symbol icon name for the current license status.
    private var licenseStatusIcon: String {
        switch licenseStatus {
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
        switch licenseStatus {
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

    /// Returns a detailed localized title string for the current license status.
    private var licenseStatusTitle: LocalizedStringResource {
        switch licenseStatus {
        case .licensed:
            "Licensed"
        case let .trial(daysRemaining):
            "Trial Active - \(daysRemaining) days remaining"
        case .expired:
            "Trial Expired"
        case .validating:
            "Validating License"
        case .unknown:
            "No Active License"
        @unknown default:
            "Unknown Status"
        }
    }

    /// Returns a detailed localized subtitle string for the current license status, if applicable.
    private var licenseStatusSubtitle: LocalizedStringResource? {
        switch licenseStatus {
        case .licensed:
            "Thank you for supporting AeroSpaceBar!"

        case let .trial(daysRemaining):
            if daysRemaining <= 3 {
                "Purchase a license to continue using AeroSpaceBar"
            } else {
                "Enjoy full access to all features"
            }

        case .expired:
            "Purchase a license to continue using AeroSpaceBar"

        case .validating:
            "Please wait while we verify your license"

        case .unknown:
            "Start your 14-day free trial or enter a license key"

        @unknown default:
            nil
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LicenseStatusSection(
            licenseStatus: .licensed,
            maskedLicenseKey: "ABCD****WXYZ"
        )

        LicenseStatusSection(
            licenseStatus: .trial(daysRemaining: 5),
            maskedLicenseKey: nil
        )

        LicenseStatusSection(
            licenseStatus: .unknown,
            maskedLicenseKey: nil
        )
    }
    .padding()
}
