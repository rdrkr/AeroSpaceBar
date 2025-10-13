// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Domain
import SwiftUI

/// Section displaying user profile information and management controls.
///
/// This section allows licensed users to customize their profile with a name and image.
/// For unlicensed users, it displays information about the benefits of purchasing a license.
struct ProfileSection: View {
    /// Whether the user has an active license.
    let isLicensed: Bool

    /// Callback to set the user's display name.
    let onSetUserName: (String) -> Void

    /// Callback to set the user's profile image.
    let onSetProfileImage: (NSImage?) -> Void

    /// The current user name from the license info.
    let userName: String

    /// The current profile image from the license info.
    let profileImage: NSImage?

    /// Whether the user is currently editing their profile name.
    @State private var isEditingProfile = false

    /// Focus state for the name text field.
    @FocusState private var isNameFieldFocused: Bool

    /// The temporary user name while editing.
    @State private var editingUserName = ""

    var body: some View {
        Section { } header: {
            VStack {
                // Profile Image
                Button {
                    if isLicensed {
                        selectProfileImage()
                    }
                } label: {
                    Group {
                        if let profileImage {
                            Image(nsImage: profileImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        ZStack {
                            if isLicensed, profileImage == nil {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundStyle(Color.themePrimary, .white)
                                            .font(.title2)
                                            .background(Circle().fill(.white))
                                    }
                                }
                                .padding(8)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
                .disabled(!isLicensed)

                // User Name or Status
                VStack {
                    if isLicensed {
                        if isEditingProfile {
                            TextField(
                                text: $editingUserName,
                                prompt: Text(LocalizedStringResource("Enter your name"))
                                    .font(.title2.bold())
                                    .foregroundStyle(.secondary)
                            ) {
                                // Empty label since we're using the prompt parameter
                            }
                            .font(.title2.bold())
                            .foregroundStyle(.secondary)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 200)
                            .focused($isNameFieldFocused)
                            .onSubmit {
                                saveProfile()
                            }
                            .onExitCommand {
                                cancelEditing()
                            }
                            .onChange(of: isNameFieldFocused) { _, newValue in
                                if !newValue, isEditingProfile {
                                    saveProfile()
                                }
                            }
                        } else {
                            Button {
                                editingUserName = userName
                                isEditingProfile = true
                                Task { @MainActor in
                                    try? await Task.sleep(for: .milliseconds(100))
                                    isNameFieldFocused = true
                                }
                            } label: {
                                HStack {
                                    Text(userName.isEmpty ? String(localized: "Set Your Name") : userName)
                                        .font(.title2.bold())
                                        .foregroundStyle(userName.isEmpty ? .secondary : .primary)

                                    if userName.isEmpty {
                                        Image(systemName: "pencil")
                                            .font(.title2.bold())
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        Text(LocalizedStringResource("Licensed User"))
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(spacing: 2) {
                            Text(LocalizedStringResource("License Not Activated"))
                                .font(.title2.bold())
                                .foregroundStyle(.secondary)

                            Text(LocalizedStringResource("Purchase a license to customize your profile"))
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .animation(.themeEaseInOutFast, value: isEditingProfile)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .onAppear {
            editingUserName = userName
        }
        .onChange(of: userName) { _, newValue in
            editingUserName = newValue
        }
    }

    // MARK: - Private Methods

    /// Presents a file picker for selecting a profile image.
    private func selectProfileImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            if let image = NSImage(contentsOf: url) {
                onSetProfileImage(image)
            }
        }
    }

    /// Saves the current profile data.
    private func saveProfile() {
        isEditingProfile = false
        isNameFieldFocused = false
        onSetUserName(editingUserName)
    }

    /// Cancels profile editing without saving.
    private func cancelEditing() {
        isEditingProfile = false
        isNameFieldFocused = false
        editingUserName = userName
    }
}

#Preview {
    ProfileSection(
        isLicensed: true,
        onSetUserName: { _ in },
        onSetProfileImage: { _ in },
        userName: "John Doe",
        profileImage: nil
    )
}
