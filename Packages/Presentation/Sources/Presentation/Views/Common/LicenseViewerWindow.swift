// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A window that displays license text for third-party dependencies.
///
/// This view provides a scrollable, read-only display of license agreements
/// for open-source dependencies used in the application.
struct LicenseViewerWindow: View {
    /// The name of the dependency
    let dependencyName: String

    /// The license text to display
    let licenseText: String

    /// Environment action to dismiss the window
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(LocalizedStringResource("\(dependencyName) License"))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .tag("license-viewer-title")

                Spacer()

                Button(LocalizedStringResource("Done")) {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .tag("license-viewer-done-button")
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // License Text
            ScrollView {
                Text(licenseText)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .tag("license-viewer-text")
            }
            .background(Color(NSColor.textBackgroundColor))
        }
        .frame(width: 600, height: 500)
        .tag("license-viewer-window")
    }
}

/// A helper function to load license text from a file in the bundle.
///
/// - Parameter fileName: The name of the license file (without extension)
/// - Returns: The license text content, or an error message if the file cannot be loaded
func loadLicenseText(fileName: String) -> String {
    // Try different directory paths
    let directories: [String?] = ["Licenses", "Resources/Licenses", "AeroSpaceBar_AeroSpaceBar.resources/Licenses", nil]

    for directory in directories {
        if let path = Bundle.main.path(forResource: fileName, ofType: "txt", inDirectory: directory) {
            do {
                return try String(contentsOfFile: path, encoding: .utf8)
            } catch {
                return "Error loading license file: \(error.localizedDescription)"
            }
        }
    }

    // Try direct URL access
    if let url = Bundle.main.url(forResource: fileName, withExtension: "txt", subdirectory: "Licenses") {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            return "Error loading license file: \(error.localizedDescription)"
        }
    }

    // Debug: List what's actually in the bundle
    let bundlePath = Bundle.main.resourcePath ?? "unknown"
    return """
    License file not found: \(fileName).txt

    Bundle resource path: \(bundlePath)

    Tried directories: Licenses, Resources/Licenses
    """
}

#Preview {
    LicenseViewerWindow(
        dependencyName: "Example Dependency",
        licenseText: """
        MIT License

        Copyright (c) 2024 Example Author

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
        """
    )
}
