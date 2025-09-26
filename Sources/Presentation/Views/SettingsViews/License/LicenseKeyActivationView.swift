// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// View for entering and activating license keys.
///
/// This view provides an interface for users to enter and activate their license keys.
/// It includes input validation, error display, and activation progress indication.
/// For licensed users, it displays the current license key in read-only mode.
struct LicenseKeyActivationView: View {
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

    /// Callback invoked when the user wants to activate a license.
    let onActivate: () -> Void

    /// Callback invoked when the user wants to clear the activation error.
    let onClearError: () -> Void

    /// Whether the license key activation interface is currently shown.
    @State private var showingActivation = false

    /// Focus state for the license key text field.
    @FocusState private var isTextFieldFocused: Bool

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
                withAnimation(.themeEaseInOutFast) {
                    if showingActivation {
                        // Clear text and errors when hiding
                        licenseKeyInput = ""
                        onClearError()
                        isTextFieldFocused = false
                    } else {
                        // Focus text field when opening for unlicensed users
                        if case .licensed = licenseStatus {
                            // No focus needed for licensed users (read-only)
                        } else {
                            // Delay focus to ensure text field is rendered
                            Task {
                                try await Task.sleep(for: .milliseconds(100))
                                isTextFieldFocused = true
                            }
                        }
                    }
                    showingActivation.toggle()
                }
            } label: {
                Label(buttonTitle, systemImage: "key.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            if showingActivation {
                VStack(spacing: 12) {
                    if case .licensed = licenseStatus {
                        // Show current license key (read-only)
                        TextField(
                            text: .constant(licenseKey),
                            prompt: Text(LocalizedStringResource("Current license key"))
                        ) {
                            // Empty label since we're using the prompt parameter
                        }
                        .font(.monospaced(.body)())
                        .labelsHidden()
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)
                        .foregroundStyle(.secondary)
                    } else {
                        // Allow license key input for unlicensed users
                        TextField(
                            text: $licenseKeyInput,
                            prompt: Text(LocalizedStringResource("Enter your license key"))
                        ) {
                            // Empty label since we're using the prompt parameter
                        }
                        .font(.monospaced(.body)())
                        .labelsHidden()
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            if !licenseKeyInput.isEmpty, !isActivating {
                                onActivate()
                            }
                        }
                    }

                    if let error = activationError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Only show activate button for unlicensed users
                    if case .licensed = licenseStatus {
                        // No buttons for licensed users
                    } else {
                        HStack {
                            Spacer()

                            Button(LocalizedStringResource("Activate")) {
                                onActivate()
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            .disabled(licenseKeyInput.isEmpty || isActivating)

                            Spacer()
                        }
                    }
                }
                .padding(.top, 8)
                .opacity(showingActivation ? 1.0 : 0.0)
            }
        }
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(.escape) {
            if showingActivation {
                withAnimation(.themeEaseInOutFast) {
                    showingActivation = false
                    licenseKeyInput = ""
                    onClearError()
                    isTextFieldFocused = false
                }
                return .handled
            }
            return .ignored
        }
        .animation(.themeEaseInOutFast, value: showingActivation)
    }
}

#Preview {
    @Previewable @State var licenseKeyInput = ""

    return VStack(spacing: 20) {
        LicenseKeyActivationView(
            licenseStatus: .unknown,
            licenseKey: "",
            licenseKeyInput: $licenseKeyInput,
            isActivating: false,
            activationError: nil,
            onActivate: { },
            onClearError: { }
        )

        LicenseKeyActivationView(
            licenseStatus: .licensed,
            licenseKey: "ABCD-EFGH-IJKL-MNOP",
            licenseKeyInput: $licenseKeyInput,
            isActivating: false,
            activationError: nil,
            onActivate: { },
            onClearError: { }
        )

        LicenseKeyActivationView(
            licenseStatus: .unknown,
            licenseKey: "",
            licenseKeyInput: $licenseKeyInput,
            isActivating: true,
            activationError: "Invalid license key format",
            onActivate: { },
            onClearError: { }
        )
    }
    .padding()
}
