// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A view that displays information about the AeroSpaceBar application.
///
/// This view presents an About window similar to macOS's "About this Mac",
/// showing the app icon, version information, and comprehensive details about the app.
struct AboutView: View {
    /// The app version from the bundle.
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    /// The app build number from the bundle.
    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        VStack(spacing: 20) {
            // App Icon
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 128, height: 128)
                .spaceCornerRadius(16)
                .standardShadow()
                .accessibleImage("App Icon")
                .tag("about-app-icon")

            // App Name
            Text(LocalizedStringResource("AeroSpaceBar"))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
                .tag("about-app-name")

            // Version
            HStack(spacing: 4) {
                Text(LocalizedStringResource("Version \(appVersion) (\(appBuild))"))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .tag("about-version")

                #if DEBUG
                    Text(LocalizedStringResource("Debug"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        .tag("about-debug-badge")
                #endif
            }

            // Description
            VStack(spacing: 12) {
                Text(
                    "A modern macOS menu bar application for managing AeroSpace window manager " +
                        "spaces and windows with a beautiful interface."
                )
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .tag("about-description")
            }
            .padding(.horizontal, 20)

            Spacer()

            // Acknowledgements
            VStack(spacing: 8) {
                Text(LocalizedStringResource("Acknowledgements"))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .tag("about-acknowledgements-title")

                HStack(spacing: 6) {
                    Button(LocalizedStringResource("AeroSpace")) {
                        if let url = URL(string: "https://github.com/nikitabobko/AeroSpace") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .settingsButton()
                    .tag("about-aerospace-link")

                    Text(LocalizedStringResource("(MIT)"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .tag("about-aerospace-license")

                    Button(LocalizedStringResource("View License")) {
                        if let path = Bundle.main.path(forResource: "AeroSpace-MIT", ofType: "txt") {
                            NSWorkspace.shared.open(URL(fileURLWithPath: path))
                        } else if
                            let path = Bundle.main.path(
                                forResource: "AeroSpace-MIT",
                                ofType: "txt",
                                inDirectory: "ThirdPartyLicenses"
                            )
                        {
                            NSWorkspace.shared.open(URL(fileURLWithPath: path))
                        }
                    }
                    .settingsButton()
                    .tag("about-view-license-button")
                }
            }

            // Made with love credit
            HStack(spacing: 4) {
                Text(LocalizedStringResource("Made with ❤️ by"))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .tag("about-made-with-love")

                Button(
                    action: {
                        if let url = URL(string: "https://github.com/rdrkr") {
                            NSWorkspace.shared.open(url)
                        }
                    },
                    label: {
                        Text(LocalizedStringResource("Ronen Druker"))
                            .font(.system(size: 11, weight: .medium))
                    }
                )
                .settingsButton()
                .tag("about-author-link")
            }
            .padding(.bottom, 10)
        }
        .padding(30)
        .frame(width: 450, height: 450)
        .tag("about-view")
    }
}

#Preview {
    AboutView()
}
