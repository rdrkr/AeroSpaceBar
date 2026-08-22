// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
// Modifications Copyright (c) 2026 Jakub Kubiak.
// Modified 2026-08-22 by Jakub Kubiak: Added fork attribution.

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

    /// State for showing license viewer sheet
    @State private var showingLicense: (dependency: String, fileName: String)?

    /// acknowledged apps and projects
    private let acknowledgedApss: [(name: String, license: String, fileName: String)] = [
        ("AeroSpace", "MIT", "AeroSpace-MIT"),
        ("VibeMeter (Scripts)", "MIT", "VibeMeter-MIT")
    ]

    /// Third-party dependencies used in the project
    private let dependencies: [(name: String, license: String, fileName: String)] = [
        ("TOMLKit", "MIT", "TOMLKit-MIT"),
        ("AsyncFileMonitor", "MIT", "AsyncFileMonitor-MIT"),
        ("Sparkle", "MIT", "Sparkle-MIT"),
        ("ModifiedCopyMacro", "MIT", "ModifiedCopyMacro-MIT")
    ]

    var body: some View {
        VStack(spacing: 20) {
            // App Icon
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 128, height: 128)
                .cornerRadius(16)
                .standardShadow()
                .accessibleImage("App Icon")
                .tag("about-app-icon")

            // App Name
            Text(LocalizedStringResource("AeroSpaceBar"))
                .font(.largeTitle)
                .foregroundColor(.primary)
                .tag("about-app-name")

            // Version
            HStack(spacing: 4) {
                Text(LocalizedStringResource("Version \(appVersion) (\(appBuild))"))
                    .font(.title3)
                    .foregroundColor(.themeSecondary)
                    .tag("about-version")

                #if DEBUG
                    Text(LocalizedStringResource("Debug"))
                        .font(.headline)
                        .foregroundColor(.themeWarning)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.themeWarning.opacity(0.1))
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
                .font(.title3)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .tag("about-description")
            }
            .padding(.horizontal, 20)

            // Acknowledgements
            VStack(spacing: 8) {
                Text(LocalizedStringResource("Acknowledgements"))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .tag("about-acknowledgements-title")

                ForEach(acknowledgedApss, id: \.name) { dependency in
                    HStack(spacing: 6) {
                        Text(dependency.name)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .tag("about-dependency-name-\(dependency.name)")

                        Text("(\(dependency.license))")
                            .secondaryText()
                            .tag("about-dependency-license-\(dependency.name)")

                        Button(LocalizedStringResource("View License")) {
                            showingLicense = (dependency.name, dependency.fileName)
                        }
                        .settingsButton()
                        .tag("about-view-license-button-\(dependency.name)")
                    }
                }

                Color.clear.frame(height: 1)

                Text(LocalizedStringResource("This app uses the following open-source libraries:"))
                    .secondaryText()
                    .tag("about-acknowledgements-subtitle")

                ForEach(dependencies, id: \.name) { dependency in
                    HStack(spacing: 6) {
                        Text(dependency.name)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .tag("about-dependency-name-\(dependency.name)")

                        Text("(\(dependency.license))")
                            .secondaryText()
                            .tag("about-dependency-license-\(dependency.name)")

                        Button(LocalizedStringResource("View License")) {
                            showingLicense = (dependency.name, dependency.fileName)
                        }
                        .settingsButton()
                        .tag("about-view-license-button-\(dependency.name)")
                    }
                }
            }

            Color.clear.frame(height: 0)

            // Original author and fork maintainer credits
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Text(LocalizedStringResource("Originally created by"))
                        .secondaryText()
                        .tag("about-original-author-label")

                    Button(
                        action: {
                            if let url = URL(string: "https://github.com/rdrkr") {
                                NSWorkspace.shared.open(url)
                            }
                        },
                        label: {
                            Text(LocalizedStringResource("Ronen Druker"))
                                .font(.subheadline)
                        }
                    )
                    .settingsButton()
                    .tag("about-original-author-link")
                }

                HStack(spacing: 4) {
                    Text(LocalizedStringResource("Fork maintained by"))
                        .secondaryText()
                        .tag("about-fork-maintainer-label")

                    Button(
                        action: {
                            if let url = URL(string: "https://github.com/Coderbeep") {
                                NSWorkspace.shared.open(url)
                            }
                        },
                        label: {
                            Text(LocalizedStringResource("Jakub Kubiak"))
                                .font(.subheadline)
                        }
                    )
                    .settingsButton()
                    .tag("about-fork-maintainer-link")
                }
            }
            .padding(.bottom, 10)
        }
        .padding(30)
        .frame(width: 450)
        .tag("about-view")
        .sheet(item: Binding(
            get: {
                showingLicense.map { LicenseItem(dependency: $0.dependency, fileName: $0.fileName) }
            },
            set: { newValue in
                showingLicense = newValue.map { ($0.dependency, $0.fileName) }
            }
        )) { item in
            LicenseViewerWindow(
                dependencyName: item.dependency,
                licenseText: loadLicenseText(fileName: item.fileName)
            )
        }
    }
}

/// A helper struct to make the license tuple Identifiable for sheet presentation.
private struct LicenseItem: Identifiable {
    let id = UUID()
    let dependency: String
    let fileName: String
}

#Preview {
    AboutView()
}
