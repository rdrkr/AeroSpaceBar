// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// View for entering and activating license keys.
///
/// This view provides an interface for users to enter and activate their license keys.
/// It includes input validation, error display, and activation progress indication.
struct LicenseKeyActivationView: View {
    /// The current license status.
    let licenseStatus: LicenseStatus

    /// The license key input text.
    @Binding var licenseKeyInput: String

    /// Whether a license activation operation is currently in progress.
    let isActivating: Bool

    /// Error message from the most recent license activation attempt, if any.
    let activationError: String?

    /// Callback invoked when the user wants to activate a license.
    let onActivate: () -> Void

    /// Callback invoked when the user wants to clear the activation error.
    let onClearError: () -> Void

    /// Whether the license key activation interface is currently shown.
    @State private var showingActivation = false

    /// Returns the appropriate button title based on the license status.
    private var buttonTitle: LocalizedStringResource {
        if case .licensed = licenseStatus {
            "Show License Key"
        } else {
            "Activate License Key"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                showingActivation.toggle()
            } label: {
                Label(buttonTitle, systemImage: "key.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            if showingActivation {
                VStack(spacing: 12) {
                    TextField(
                        text: $licenseKeyInput,
                        prompt: Text(LocalizedStringResource("Enter your license key"))
                            .font(.body)
                            .foregroundStyle(.secondary)
                    ) {
                        // Empty label since we're using the prompt parameter
                    }
                    .font(.monospaced(.body)())
                    .textFieldStyle(.roundedBorder)
                    .environment(\.layoutDirection, .leftToRight)
                    .autocorrectionDisabled()

                    if let error = activationError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack {
                        Button(LocalizedStringResource("Cancel")) {
                            showingActivation = false
                            licenseKeyInput = ""
                            onClearError()
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        Button(LocalizedStringResource("Activate")) {
                            onActivate()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(licenseKeyInput.isEmpty || isActivating)
                    }
                }
                .padding(.top, 8)
            }
        }
        .animation(.themeEaseInOutFast, value: showingActivation)
    }
}

#Preview {
    @Previewable @State var licenseKeyInput = ""

    return VStack(spacing: 20) {
        LicenseKeyActivationView(
            licenseStatus: .unknown,
            licenseKeyInput: $licenseKeyInput,
            isActivating: false,
            activationError: nil,
            onActivate: { },
            onClearError: { }
        )

        LicenseKeyActivationView(
            licenseStatus: .licensed,
            licenseKeyInput: $licenseKeyInput,
            isActivating: false,
            activationError: nil,
            onActivate: { },
            onClearError: { }
        )

        LicenseKeyActivationView(
            licenseStatus: .unknown,
            licenseKeyInput: $licenseKeyInput,
            isActivating: true,
            activationError: "Invalid license key format",
            onActivate: { },
            onClearError: { }
        )
    }
    .padding()
}
