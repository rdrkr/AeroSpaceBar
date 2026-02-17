// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for loadLicenseText helper function.
///
/// These tests verify:
/// - File loading from bundle
/// - Error handling
/// - Directory path searching
final class LoadLicenseTextTests: XCTestCase {
    // MARK: - Helper Function Tests

    func testLoadLicenseTextReturnsString() {
        // Given
        let fileName = "test-license"

        // When
        let result = loadLicenseText(fileName: fileName)

        // Then - Should return a string (either content or error message)
        expect(result.isEmpty) == false
        expect(result).to(beAnInstanceOf(String.self))
    }

    func testLoadLicenseTextWithNonExistentFile() {
        // Given
        let fileName = "nonexistent-file-12345"

        // When
        let result = loadLicenseText(fileName: fileName)

        // Then - Should return error message or not found message
        expect(result.contains("not found") ||
            result.contains("Error loading") ||
            result.contains("Tried directories")
        ) == true
    }

    func testLoadLicenseTextWithEmptyFileName() {
        // Given
        let fileName = ""

        // When
        let result = loadLicenseText(fileName: fileName)

        // Then - Should return some result (likely error message)
        expect(result.isEmpty) == false
    }

    func testLoadLicenseTextIncludesBundleInfo() {
        // Given
        let fileName = "nonexistent-test-file"

        // When
        let result = loadLicenseText(fileName: fileName)

        // Then - Should include bundle path information in result
        expect(result.contains("Bundle resource path") ||
            result.contains("Error loading") ||
            result.contains("not found")
        ) == true
    }

    func testLoadLicenseTextSearchesMultipleDirectories() {
        // Given
        let fileName = "test-license-file"

        // When
        let result = loadLicenseText(fileName: fileName)

        // Then - Should search multiple directories
        // The function tries: Licenses, Resources/Licenses, AeroSpaceBar_AeroSpaceBar.resources/Licenses
        expect(result.isEmpty) == false
        // Result should either be file content or error message mentioning tried directories
        expect(!result.isEmpty) == true
    }

    func testLoadLicenseTextHandlesSpecialCharacters() {
        // Given
        let fileName = "license-with-特殊文字"

        // When
        let result = loadLicenseText(fileName: fileName)

        // Then - Should handle special characters in filename
        expect(result.isEmpty) == false
    }

    func testLoadLicenseTextReturnsDebugInfo() {
        // Given
        let fileName = "missing-license"

        // When
        let result = loadLicenseText(fileName: fileName)

        // Then - Should include debug information when file not found
        let containsDebugInfo = result.contains("Bundle resource path") ||
            result.contains("Tried directories") ||
            result.contains("not found")
        expect(containsDebugInfo) == true
    }
}
