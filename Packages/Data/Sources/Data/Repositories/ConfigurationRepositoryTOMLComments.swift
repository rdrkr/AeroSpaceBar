// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import Foundation

/// TOML comment annotation helpers for `ConfigurationRepository`.
///
/// These are pure string transformations over generated TOML — they read no
/// repository state — so they live apart from the reactive settings surface.
extension ConfigurationRepository {
    /// Adds helpful comments to TOML string for enum values and configuration guidance.
    func addEnumComments(to tomlString: String) -> String {
        var annotatedString = tomlString

        // Add header comment
        let header = """
        # AeroSpaceBar Configuration File
        # This file stores all your settings in TOML format.
        # Changes are automatically saved when modified through the UI.
        # You can edit this file directly - changes will be reflected immediately.


        """

        // Generate enum comments dynamically using generics
        let enumCommentMappings: [(String, String)] = [
            ("[spaces]", generateSectionComment(
                "Spaces appearance mode",
                for: SpacesAppearanceMode.self,
                key: "appearance-mode"
            )),
            ("[groups]", generateSectionComment(
                "Groups appearance mode",
                for: GroupsAppearanceMode.self,
                key: "appearance-mode"
            )),
            ("log-level =", generateEnumComment(for: Logger.Level.self))
        ]

        for (pattern, comment) in enumCommentMappings {
            if let range = annotatedString.range(of: pattern) {
                if pattern.hasPrefix("["), pattern.hasSuffix("]") {
                    // For section headers, add comment after the section
                    let endIndex = annotatedString.lineRange(for: range).upperBound
                    annotatedString.insert(contentsOf: comment + "\n", at: endIndex)
                } else {
                    // For regular keys, add comment before the line
                    let insertIndex = annotatedString.lineRange(for: range).lowerBound
                    annotatedString.insert(contentsOf: comment + "\n", at: insertIndex)
                }
            }
        }

        return header + annotatedString
    }

    /// Generates a comment string for an enum type that conforms to CaseIterable and RawRepresentable.
    /// - Parameter enumType: The enum type to generate comments for
    /// - Returns: A formatted comment string with all possible enum values
    func generateEnumComment<T: CaseIterable & RawRepresentable>(
        for enumType: T.Type
    ) -> String where T.RawValue == String {
        let values = enumType.allCases.map { "\"\($0.rawValue)\"" }.joined(separator: ", ")
        return "# Supported values: \(values)"
    }

    /// Generates a section-specific comment for an enum type.
    /// - Parameters:
    ///   - description: Description of what the enum controls
    ///   - enumType: The enum type to generate comments for
    ///   - key: The TOML key name for this enum
    /// - Returns: A formatted comment string with description and all possible enum values
    func generateSectionComment<T: CaseIterable & RawRepresentable>(
        _ description: String,
        for enumType: T.Type,
        key: String
    ) -> String where T.RawValue == String {
        let values = enumType.allCases.map { "\"\($0.rawValue)\"" }.joined(separator: ", ")
        return "# \(description): \(key) = <value>\n# Supported values: \(values)"
    }
}
