// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
internal import TOMLKit

/// Represents the minimal AeroSpace TOML configuration structure
/// We only care about some of the configuration keys
public struct AeroSpaceConfiguration: Codable {
    /// On-focus-changed callbacks
    var onFocusChanged: [String]?

    /// Coding keys
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case onFocusChanged = "on-focus-changed"
    }

    /// Decodes an `AeroSpaceConfiguration` from a TOML file at the provided path
    /// - Parameter fileURL: The path to the TOML file
    /// - Returns: The decoded `AeroSpaceConfiguration`
    /// - Throws: An error if the decoding fails
    public static func decode(from fileURL: URL) throws -> AeroSpaceConfiguration {
        let data = try Data(contentsOf: fileURL)
        guard let content = String(data: data, encoding: .utf8) else {
            throw NSError(
                domain: String(describing: self),
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to decode file contents as UTF-8"]
            )
        }

        let table = try TOMLTable(string: content)
        let decoder = TOMLDecoder()
        return try decoder.decode(AeroSpaceConfiguration.self, from: table)
    }

    /// Appends a command to the `on-focus-changed` array in the TOML at path if not present
    /// - Parameter fileURL: The path to the TOML file
    /// - Parameter command: The command to append
    /// - Returns: `true` if the command was appended; `false` if it already existed
    /// - Throws: An error if the appending fails
    @discardableResult
    public static func appendOnFocusChanged(at fileURL: URL, command: String) throws -> Bool {
        var configuration = try decode(from: fileURL)

        if let callbacks = configuration.onFocusChanged, callbacks.contains(command) {
            return false
        }

        if configuration.onFocusChanged == nil {
            configuration.onFocusChanged = [command]
        } else {
            configuration.onFocusChanged?.append(command)
        }

        try configuration.encode(to: fileURL)

        return true
    }

    /// Removes a command from the `on-focus-changed` array in the TOML at path if present
    /// - Parameter fileURL: The path to the TOML file
    /// - Parameter command: The command to remove
    /// - Returns: `true` if the command was removed; `false` if it did not exist
    /// - Throws: An error if the removing fails

    @discardableResult
    public static func removeOnFocusChanged(at fileURL: URL, command: String) throws -> Bool {
        var configuration = try decode(from: fileURL)

        if let callbacks = configuration.onFocusChanged, !callbacks.contains(command) {
            return false
        }

        configuration.onFocusChanged = configuration.onFocusChanged?.filter { $0 != command }
        try configuration.encode(to: fileURL)

        return true
    }

    /// Encodes only this struct's keys into the TOML file at `fileURL`, preserving other keys.
    /// Behavior:
    /// - If a key exists, it is replaced in-place (position preserved)
    /// - If a key does not exist, it is added at the top, followed by the existing content
    /// - Parameter fileURL: The path to the TOML file
    /// - Throws: An error if the encoding fails
    public func encode(to fileURL: URL) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let originalContent = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""

        // Process all CodingKeys dynamically
        var finalContent = originalContent

        for codingKey in CodingKeys.allCases {
            let key = codingKey.rawValue
            let value = getValue(for: codingKey)

            if
                let region = AeroSpaceConfiguration.findKeyValueRegion(
                    for: key,
                    in: finalContent
                )
            {
                if let value {
                    // Replace existing value in-place
                    let newValue = formatKeyValue(key: key, value: value)
                    finalContent = AeroSpaceConfiguration.replaceRegion(
                        in: finalContent,
                        region: region,
                        with: newValue
                    )
                } else {
                    // Remove existing key-value block
                    finalContent = AeroSpaceConfiguration.removeRegion(
                        in: finalContent,
                        region: region
                    )
                }
            } else if let value {
                // Prepend new key at the top
                let newValue = formatKeyValue(key: key, value: value)
                finalContent = newValue + "\n\n" + finalContent
            }
        }

        // Write the modified content back
        try finalContent.write(to: fileURL, atomically: false, encoding: .utf8)
    }

    // MARK: - Private helpers

    /// Gets the value for a given coding key using reflection
    private func getValue(for codingKey: CodingKeys) -> Any? {
        switch codingKey {
        case .onFocusChanged:
            onFocusChanged
        }
    }

    /// Formats a key-value pair as TOML
    private func formatKeyValue(key: String, value: Any) -> String {
        if let array = value as? [String] {
            "\(key) = [\n" + array.map { "    '\($0)'" }.joined(separator: ",\n") + "\n]"
        } else if let string = value as? String {
            "\(key) = '\(string)'"
        } else if let int = value as? Int {
            "\(key) = \(int)"
        } else if let double = value as? Double {
            "\(key) = \(double)"
        } else if let bool = value as? Bool {
            "\(key) = \(bool)"
        } else {
            // Fallback for other types
            "\(key) = '\(String(describing: value))'"
        }
    }

    /// Represents a region in the TOML file (start line to end line, 0-based)
    private struct KeyValueRegion {
        let startLine: Int
        let endLine: Int
        let startIndex: String.Index
        let endIndex: String.Index
    }

    /// Finds the exact region (start line to end line) of a key-value pair in TOML content
    /// Handles multi-line arrays by finding the closing bracket
    private static func findKeyValueRegion(for key: String, in content: String) -> KeyValueRegion? {
        let lines = content.components(separatedBy: .newlines)

        for (lineIndex, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.starts(with: "\(key) =") {
                // Found the key, now find where the value ends
                let startLine = lineIndex
                var endLine = startLine

                // Check if this is a multi-line array
                if trimmedLine.contains("["), !trimmedLine.contains("]") {
                    // Multi-line array, find the closing bracket
                    for lineIndex in (startLine + 1) ..< lines.count where lines[lineIndex].contains("]") {
                        endLine = lineIndex
                        break
                    }
                }

                // Calculate string indices for the region
                let startIndex = content.index(
                    content.startIndex,
                    offsetBy: lines.prefix(startLine).joined(separator: "\n").count + (startLine > 0 ? 1 : 0)
                )
                let endIndex = content.index(
                    content.startIndex,
                    offsetBy: lines.prefix(endLine + 1).joined(separator: "\n").count
                )

                return KeyValueRegion(
                    startLine: startLine,
                    endLine: endLine,
                    startIndex: startIndex,
                    endIndex: endIndex
                )
            }
        }

        return nil
    }

    /// Replaces a region in the content with new text
    private static func replaceRegion(in content: String, region: KeyValueRegion, with newText: String) -> String {
        let before = content[content.startIndex ..< region.startIndex]
        let after = content[region.endIndex ..< content.endIndex]
        return String(before) + newText + String(after)
    }

    /// Removes a region from the content
    private static func removeRegion(in content: String, region: KeyValueRegion) -> String {
        let before = content[content.startIndex ..< region.startIndex]
        let after = content[region.endIndex ..< content.endIndex]

        // Remove extra newlines if the region spanned multiple lines
        let result = String(before) + String(after)

        // Clean up extra blank lines that might be left
        let lines = result.components(separatedBy: .newlines)
        let cleanedLines = lines.enumerated().compactMap { index, line -> String? in
            // Remove consecutive blank lines
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if index > 0, lines[index - 1].trimmingCharacters(in: .whitespaces).isEmpty {
                    return nil
                }
            }
            return line
        }

        return cleanedLines.joined(separator: "\n")
    }
}
