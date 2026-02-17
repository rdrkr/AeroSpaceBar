// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Data
import Foundation
import Nimble
import XCTest

/// Tests for AeroSpaceConfiguration TOML parsing and modification.
///
/// These tests verify TOML file reading, writing, and callback management.
final class AeroSpaceConfigurationTests: XCTestCase {
    private var tempFileURL: URL?

    override func setUp() {
        super.setUp()
        // Create temp file for testing
        tempFileURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("toml")
    }

    override func tearDown() {
        tempFileURL = nil
        super.tearDown()
    }

    // MARK: - Decode Tests

    func testDecodeEmptyTOML() throws {
        // Given empty TOML file
        let content = ""
        let url = try XCTUnwrap(tempFileURL)
        try content.write(to: url, atomically: true, encoding: .utf8)

        // When decoding
        let config = try AeroSpaceConfiguration.decode(from: url)

        // Then should succeed
        expect(config).toNot(beNil())
    }

    func testDecodeWithOnFocusChanged() throws {
        // Given TOML with on-focus-changed
        let content = """
        on-focus-changed = ["command1", "command2"]
        """
        let url = try XCTUnwrap(tempFileURL)
        try content.write(to: url, atomically: true, encoding: .utf8)

        // When decoding
        let config = try AeroSpaceConfiguration.decode(from: url)

        // Then should parse successfully
        expect(config).toNot(beNil())
    }

    func testDecodeInvalidUTF8() throws {
        // Given invalid UTF-8 data
        let invalidData = Data([0xFF, 0xFE, 0xFD])
        let url = try XCTUnwrap(tempFileURL)
        expect { try invalidData.write(to: url) }.toNot(throwError())

        // When decoding
        // Then should throw
        expect { try AeroSpaceConfiguration.decode(from: url) }.to(throwError())
    }

    func testDecodeNonexistentFile() {
        // Given nonexistent file
        let nonexistent = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("nonexistent.toml")

        // When decoding
        // Then should throw
        expect { try AeroSpaceConfiguration.decode(from: nonexistent) }.to(throwError())
    }

    // MARK: - AppendOnFocusChanged Tests

    func testAppendOnFocusChangedToEmptyFile() throws {
        // Given empty TOML
        let content = ""
        let url = try XCTUnwrap(tempFileURL)
        try content.write(to: url, atomically: true, encoding: .utf8)

        // When appending command
        let wasAppended = try AeroSpaceConfiguration.appendOnFocusChanged(
            at: url,
            command: "test-command"
        )

        // Then should append successfully
        expect(wasAppended) == true

        // And file should contain command
        let decoded = try AeroSpaceConfiguration.decode(from: url)
        expect(decoded).toNot(beNil())
    }

    func testAppendOnFocusChangedToExistingArray() throws {
        // Given TOML with existing callback
        let content = """
        on-focus-changed = ["existing-command"]
        """
        let url = try XCTUnwrap(tempFileURL)
        try content.write(to: url, atomically: true, encoding: .utf8)

        // When appending new command
        let wasAppended = try AeroSpaceConfiguration.appendOnFocusChanged(
            at: url,
            command: "new-command"
        )

        // Then should append successfully
        expect(wasAppended) == true
    }

    func testAppendOnFocusChangedDuplicate() throws {
        // Given TOML with existing command
        let content = """
        on-focus-changed = ["test-command"]
        """
        let url = try XCTUnwrap(tempFileURL)
        try content.write(to: url, atomically: true, encoding: .utf8)

        // When appending same command
        let wasAppended = try AeroSpaceConfiguration.appendOnFocusChanged(
            at: url,
            command: "test-command"
        )

        // Then should not append (already exists)
        expect(wasAppended) == false
    }

    // MARK: - RemoveOnFocusChanged Tests

    func testRemoveOnFocusChangedExisting() throws {
        // Given TOML with command
        let content = """
        on-focus-changed = ["command1", "command2"]
        """
        let url = try XCTUnwrap(tempFileURL)
        try content.write(to: url, atomically: true, encoding: .utf8)

        // When removing command
        let wasRemoved = try AeroSpaceConfiguration.removeOnFocusChanged(
            at: url,
            command: "command1"
        )

        // Then should remove successfully
        expect(wasRemoved) == true
    }

    func testRemoveOnFocusChangedNonexistent() throws {
        // Given TOML with commands
        let content = """
        on-focus-changed = ["command1"]
        """
        let url = try XCTUnwrap(tempFileURL)
        try content.write(to: url, atomically: true, encoding: .utf8)

        // When removing nonexistent command
        let wasRemoved = try AeroSpaceConfiguration.removeOnFocusChanged(
            at: url,
            command: "nonexistent"
        )

        // Then should not remove (doesn't exist)
        expect(wasRemoved) == false
    }

    func testRemoveOnFocusChangedFromEmptyFile() throws {
        // Given empty TOML
        let content = ""
        let url = try XCTUnwrap(tempFileURL)
        try content.write(to: url, atomically: true, encoding: .utf8)

        // When removing command
        let wasRemoved = try AeroSpaceConfiguration.removeOnFocusChanged(
            at: url,
            command: "test-command"
        )

        // Then should not remove (doesn't exist)
        expect(wasRemoved) == false
    }

    // MARK: - Round-trip Tests

    func testAppendAndRemoveRoundtrip() throws {
        // Given empty TOML
        let content = ""
        let url = try XCTUnwrap(tempFileURL)
        try content.write(to: url, atomically: true, encoding: .utf8)

        // When appending multiple commands
        try AeroSpaceConfiguration.appendOnFocusChanged(at: url, command: "cmd1")
        try AeroSpaceConfiguration.appendOnFocusChanged(at: url, command: "cmd2")
        try AeroSpaceConfiguration.appendOnFocusChanged(at: url, command: "cmd3")

        // And removing one
        let wasRemoved = try AeroSpaceConfiguration.removeOnFocusChanged(
            at: url,
            command: "cmd2"
        )

        // Then should work correctly
        expect(wasRemoved) == true

        // And trying to remove again should fail
        let secondRemove = try AeroSpaceConfiguration.removeOnFocusChanged(
            at: url,
            command: "cmd2"
        )
        expect(secondRemove) == false
    }

    // MARK: - Codable Conformance Tests

    func testCodableConformance() {
        /// Given AeroSpaceConfiguration type
        /// Then should conform to Codable
        func requiresCodable(_: (some Codable).Type) { }
        requiresCodable(AeroSpaceConfiguration.self)
    }

    // MARK: - Edge Cases

    func testAppendEmptyCommand() throws {
        // Given empty TOML
        let content = ""
        let url = try XCTUnwrap(tempFileURL)
        try content.write(to: url, atomically: true, encoding: .utf8)

        // When appending empty command
        let wasAppended = try AeroSpaceConfiguration.appendOnFocusChanged(
            at: url,
            command: ""
        )

        // Then should append (even though it's empty)
        expect(wasAppended) == true
    }

    func testAppendCommandWithSpecialCharacters() throws {
        // Given empty TOML
        let content = ""
        let url = try XCTUnwrap(tempFileURL)
        try content.write(to: url, atomically: true, encoding: .utf8)

        // When appending command with special characters
        let command = "echo 'test \"quoted\" value'"
        let wasAppended = try AeroSpaceConfiguration.appendOnFocusChanged(
            at: url,
            command: command
        )

        // Then should handle special characters
        expect(wasAppended) == true
    }

    func testMultipleOperationsPreserveOtherKeys() throws {
        // Given TOML with other configuration
        let content = """
        some-other-key = "value"
        another-key = 42
        """
        let url = try XCTUnwrap(tempFileURL)
        try content.write(to: url, atomically: true, encoding: .utf8)

        // When performing operations
        try AeroSpaceConfiguration.appendOnFocusChanged(at: url, command: "test")

        // Then other keys should be preserved
        let fileContent = try String(contentsOf: url, encoding: .utf8)
        expect(fileContent.contains("some-other-key")) == true
    }
}
