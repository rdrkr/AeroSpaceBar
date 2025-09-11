// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

#if DEBUG
    import SwiftUI

    /// A reusable toggle component for feature flags in developer settings.
    ///
    /// This component provides a consistent interface for enabling/disabling feature flags
    /// during development and testing. Only available in debug builds.
    struct FeatureFlagToggle: View {
        /// The title text for the feature flag
        let title: String

        /// The description text explaining what the feature flag does
        let description: String

        /// The binding to the boolean value that controls the feature flag state
        @Binding var isEnabled: Bool

        /// Creates a new feature flag toggle.
        /// - Parameters:
        ///   - title: The title text for the feature flag
        ///   - description: The description text explaining what the feature flag does
        ///   - isEnabled: A binding to the boolean value that controls the feature flag state
        init(
            title: String,
            description: String,
            isEnabled: Binding<Bool>
        ) {
            self.title = title
            self.description = description
            _isEnabled = isEnabled
        }

        var body: some View {
            VStack(alignment: .leading) {
                Toggle(isOn: $isEnabled) {
                    Text(LocalizedStringResource(stringLiteral: title))
                        .font(.themeBody)
                        .tag("feature-flag-toggle-title")
                }
                .toggleStyle(.switch)
                .tag("feature-flag-toggle-switch")

                Text(LocalizedStringResource(stringLiteral: description))
                    .secondaryText()
                    .fixedSize(horizontal: false, vertical: true)
                    .tag("feature-flag-toggle-description")
            }
            .tag("feature-flag-toggle")
        }
    }

    #Preview {
        Form {
            Section {
                FeatureFlagToggle(
                    title: "Enable Spaces",
                    description: "Show/hide the Spaces feature in the menu bar and settings",
                    isEnabled: .constant(true)
                )
            }
        }
        .formStyle(.grouped)
        .padding(.top, -20)
    }
#endif
