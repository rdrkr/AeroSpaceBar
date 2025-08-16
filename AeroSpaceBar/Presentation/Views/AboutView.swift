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
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

            // App Name
            Text("AeroSpaceBar")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)

            // Version
            HStack(spacing: 4) {
                Text("Version \(appVersion) (\(appBuild))")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                #if DEBUG
                    Text("Debug")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
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
            }
            .padding(.horizontal, 20)

            Spacer()

            // Acknowledgements
            VStack(spacing: 8) {
                Text("Acknowledgements")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)

                HStack(spacing: 6) {
                    Button("AeroSpace") {
                        if let url = URL(string: "https://github.com/nikitabobko/AeroSpace") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)

                    Text("(MIT)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Button("View License") {
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
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                }
            }

            // Made with love credit
            HStack(spacing: 4) {
                Text("Made with ❤️ by")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Button(
                    action: {
                        if let url = URL(string: "https://github.com/rdrkr") {
                            NSWorkspace.shared.open(url)
                        }
                    },
                    label: {
                        Text("Ronen Druker")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.blue)
                    }
                )
                .buttonStyle(.plain)
            }
            .padding(.bottom, 10)
        }
        .padding(30)
        .frame(width: 450, height: 450)
    }
}

#Preview {
    AboutView()
}
