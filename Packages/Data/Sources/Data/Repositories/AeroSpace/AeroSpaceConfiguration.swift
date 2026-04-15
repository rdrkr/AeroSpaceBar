// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
internal import TOMLKit

/// Represents the minimal AeroSpace TOML configuration structure
/// We only care about some of the configuration keys
internal struct AeroSpaceConfiguration: Codable {
    /// On-focus-changed callbacks
    private var onFocusChanged: [String]?

    /// Exec-on-workspace-change callback (single process spec: `[bin, arg, ...]`).
    ///
    /// Decoded so we can detect user-managed values and avoid clobbering them,
    /// but intentionally excluded from the generic `encode(to:)` iteration so
    /// that editing `onFocusChanged` does not rewrite this key. It is written
    /// exclusively through `installExecOnWorkspaceChange` / `removeExecOnWorkspaceChange`.
    private var execOnWorkspaceChange: [String]?

    /// Coding keys
    private enum CodingKeys: String, CodingKey {
        case onFocusChanged = "on-focus-changed"
        case execOnWorkspaceChange = "exec-on-workspace-change"
    }

    /// Keys that the generic `encode(to:)` flow is allowed to write.
    /// `execOnWorkspaceChange` is intentionally omitted — see property docs.
    private static let encodedKeys: [CodingKeys] = [.onFocusChanged]

    /// Result of attempting to install `exec-on-workspace-change`.
    internal enum ExecOnWorkspaceChangeResult: Equatable {
        /// Key was absent; our value was written.
        case installed
        /// Key was already present with our exact value; nothing changed.
        case alreadyInstalled
        /// Key was present with a different value (user-managed); nothing changed.
        case conflict(existing: [String])
    }

    /// Decodes an `AeroSpaceConfiguration` from a TOML file at the provided path
    /// - Parameter fileURL: The path to the TOML file
    /// - Returns: The decoded `AeroSpaceConfiguration`
    /// - Throws: An error if the decoding fails
    internal static func decode(from fileURL: URL) throws -> Self {
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
        return try decoder.decode(Self.self, from: table)
    }

    /// Appends a command to the `on-focus-changed` array in the TOML at path if not present
    /// - Parameter fileURL: The path to the TOML file
    /// - Parameter command: The command to append
    /// - Returns: `true` if the command was appended; `false` if it already existed
    /// - Throws: An error if the appending fails
    @discardableResult
    internal static func appendOnFocusChanged(at fileURL: URL, command: String) throws -> Bool {
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

    // Removes a command from the `on-focus-changed` array in the TOML at path if present
    // - Parameter fileURL: The path to the TOML file
    // - Parameter command: The command to remove
    // - Returns: `true` if the command was removed; `false` if it did not exist
    // - Throws: An error if the removing fails

    @discardableResult
    static func removeOnFocusChanged(at fileURL: URL, command: String) throws -> Bool {
        var configuration = try decode(from: fileURL)

        // If onFocusChanged is nil or empty, the command doesn't exist
        guard let callbacks = configuration.onFocusChanged, !callbacks.isEmpty else {
            return false
        }

        // If the command is not in the callbacks, it doesn't exist
        guard callbacks.contains(command) else {
            return false
        }

        configuration.onFocusChanged = callbacks.filter { $0 != command }
        try configuration.encode(to: fileURL)

        return true
    }

    /// Installs the `exec-on-workspace-change` callback if absent or empty.
    ///
    /// AeroSpace allows only a single `exec-on-workspace-change` value (one process spec).
    /// A commented-out placeholder (e.g. `exec-on-workspace-change = [ # ... ]`) decodes
    /// to an empty array; we treat that as absent and insert our entries inside the
    /// existing block without touching any pre-existing comments or blank lines.
    /// A non-empty value that differs from ours is treated as user-managed and left alone.
    /// - Parameters:
    ///   - fileURL: The path to the TOML file
    ///   - command: The process spec to install (e.g. `['/usr/bin/osascript', '-e', '...']`)
    /// - Returns: An `ExecOnWorkspaceChangeResult` describing the outcome
    /// - Throws: An error if decoding or writing fails
    @discardableResult
    internal static func installExecOnWorkspaceChange(
        at fileURL: URL,
        command: [String]
    ) throws -> ExecOnWorkspaceChangeResult {
        let configuration = try decode(from: fileURL)

        if let existing = configuration.execOnWorkspaceChange, !existing.isEmpty {
            return existing == command ? .alreadyInstalled : .conflict(existing: existing)
        }

        // Value is nil or an empty array — either way, install ours.
        let key = CodingKeys.execOnWorkspaceChange.rawValue
        let content = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""

        let newContent: String = if let region = findKeyValueRegion(for: key, in: content) {
            // Block already exists (possibly with user comments). Insert our entries
            // before the closing `]`, preserving everything already inside.
            insertEntriesInArrayBlock(in: content, region: region, entries: command)
        } else {
            // Key absent entirely — prepend a new block.
            formatMultilineArray(key: key, values: command) + "\n\n" + content
        }

        try newContent.write(to: fileURL, atomically: false, encoding: .utf8)
        return .installed
    }

    /// Removes the `exec-on-workspace-change` callback if it matches `command`.
    ///
    /// Only removes the key when its current value exactly equals `command` — this
    /// prevents removing a user-customized callback. When the block also contains
    /// user comments/blank lines, only our entry lines are stripped and the block
    /// (with its comments) is preserved. If nothing non-whitespace remains, the
    /// entire block is removed.
    /// - Parameters:
    ///   - fileURL: The path to the TOML file
    ///   - command: The process spec previously installed
    /// - Returns: `true` if the key was removed; `false` if absent or different
    /// - Throws: An error if decoding or writing fails
    @discardableResult
    internal static func removeExecOnWorkspaceChange(
        at fileURL: URL,
        command: [String]
    ) throws -> Bool {
        let configuration = try decode(from: fileURL)
        guard configuration.execOnWorkspaceChange == command else { return false }

        let content = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
        guard
            let region = findKeyValueRegion(
                for: CodingKeys.execOnWorkspaceChange.rawValue,
                in: content
            )
        else {
            return false
        }

        let updated = removeOurEntriesFromArrayBlock(in: content, region: region, entries: command)
        try updated.write(to: fileURL, atomically: false, encoding: .utf8)
        return true
    }

    /// Inserts `entries` as TOML string-array values just before the closing `]`
    /// of an existing array block, preserving all pre-existing lines (including
    /// comments and blank lines). For single-line blocks (e.g. `key = []`), the
    /// block is replaced by a fresh multi-line array since there's nothing to preserve.
    /// - Parameters:
    ///   - content: The full TOML file contents
    ///   - region: The region describing the existing key-value block
    ///   - entries: The string values to insert
    /// - Returns: The updated TOML content
    private static func insertEntriesInArrayBlock(
        in content: String,
        region: KeyValueRegion,
        entries: [String]
    ) -> String {
        // Single-line block like `key = []` — replace with a fresh multi-line block.
        if region.startLine == region.endLine {
            let blockText = String(content[region.startIndex ..< region.endIndex])
            let key = blockText
                .split(separator: "=", maxSplits: 1)
                .first
                .map { $0.trimmingCharacters(in: .whitespaces) } ?? CodingKeys.execOnWorkspaceChange.rawValue
            return replaceRegion(
                in: content,
                region: region,
                with: formatMultilineArray(key: key, values: entries)
            )
        }

        var lines = content.components(separatedBy: "\n")
        let closingLineIndex = region.endLine

        // Detect indentation from any existing non-blank content line within the block.
        // Fall back to 4 spaces (matches formatMultilineArray) if the block is empty.
        var indent = "    "
        for idx in (region.startLine + 1) ..< closingLineIndex {
            let line = lines[idx]
            if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                indent = String(line.prefix(while: { $0 == " " || $0 == "\t" }))
                break
            }
        }

        let newEntryLines = entries.map { "\(indent)'\($0)'," }
        lines.insert(contentsOf: newEntryLines, at: closingLineIndex)

        return lines.joined(separator: "\n")
    }

    /// Removes lines inside the array block that exactly match one of our entry
    /// values (comparing trimmed text against known TOML quote/comma variants).
    /// All other lines (including user comments and blank lines) are preserved.
    /// If the block body becomes empty (no non-whitespace lines), the whole block is removed.
    /// - Parameters:
    ///   - content: The full TOML file contents
    ///   - region: The region describing the existing key-value block
    ///   - entries: Our entry string values to remove
    /// - Returns: The updated TOML content
    private static func removeOurEntriesFromArrayBlock(
        in content: String,
        region: KeyValueRegion,
        entries: [String]
    ) -> String {
        // Single-line block — the whole block was written by us; remove it entirely.
        if region.startLine == region.endLine {
            return removeRegion(in: content, region: region)
        }

        let lines = content.components(separatedBy: "\n")

        // Match all plausible TOML string representations, with or without trailing comma.
        let patterns: Set<String> = Set(entries.flatMap { value in
            ["'\(value)',", "'\(value)'", "\"\(value)\",", "\"\(value)\""]
        })

        var remainingBody: [String] = []
        for idx in (region.startLine + 1) ..< region.endLine {
            let trimmed = lines[idx].trimmingCharacters(in: .whitespaces)
            if patterns.contains(trimmed) { continue }
            remainingBody.append(lines[idx])
        }

        // If nothing non-whitespace remains inside the block, drop the whole block.
        let hasContent = remainingBody.contains { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        if !hasContent {
            return removeRegion(in: content, region: region)
        }

        var newLines = Array(lines[0 ... region.startLine])
        newLines.append(contentsOf: remainingBody)
        newLines.append(contentsOf: lines[region.endLine ..< lines.count])

        return newLines.joined(separator: "\n")
    }

    /// Formats a TOML multi-line array of string values.
    /// - Parameters:
    ///   - key: The TOML key
    ///   - values: The array values
    /// - Returns: The formatted TOML snippet
    private static func formatMultilineArray(key: String, values: [String]) -> String {
        "\(key) = [\n" +
            values.map { "    '\($0)'" }.joined(separator: ",\n") +
            "\n]"
    }

    /// Encodes only this struct's keys into the TOML file at `fileURL`, preserving other keys.
    /// Behavior:
    /// - If a key exists, it is replaced in-place (position preserved)
    /// - If a key does not exist, it is added at the top, followed by the existing content
    /// - Parameter fileURL: The path to the TOML file
    /// - Throws: An error if the encoding fails
    func encode(to fileURL: URL) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let originalContent = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""

        // Process only keys owned by the generic encode flow.
        var finalContent = originalContent

        for codingKey in Self.encodedKeys {
            let key = codingKey.rawValue
            let value = getValue(for: codingKey)

            if
                let region = Self.findKeyValueRegion(
                    for: key,
                    in: finalContent
                )
            {
                if let value {
                    // Replace existing value in-place
                    let newValue = formatKeyValue(key: key, value: value)
                    finalContent = Self.replaceRegion(
                        in: finalContent,
                        region: region,
                        with: newValue
                    )
                } else {
                    // Remove existing key-value block
                    finalContent = Self.removeRegion(
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
        case .execOnWorkspaceChange:
            execOnWorkspaceChange
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
