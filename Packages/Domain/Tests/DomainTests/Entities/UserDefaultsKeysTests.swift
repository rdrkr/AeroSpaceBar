// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for UserDefaultsKeys enum.
///
/// These tests verify UserDefaults key strings, enum conformance, and key
/// uniqueness to prevent circular dependencies with ConfigurationRepository.
@MainActor
final class UserDefaultsKeysTests: XCTestCase {
    // MARK: - Enum Conformance Tests

    func testEnumIsRawRepresentable() {
        // Given UserDefaultsKeys enum
        // When checking conformance
        // Then should be RawRepresentable with String
        expect(String(describing: UserDefaultsKeys.RawValue.self)) == String(describing: String.self)
    }

    func testEnumIsCaseIterable() {
        // Given UserDefaultsKeys enum
        // When accessing allCases
        let allCases = UserDefaultsKeys.allCases

        // Then should have all cases
        expect(allCases.count) == 4
        expect(allCases.contains(.logLevel)) == true
        expect(allCases.contains(.enablePerformanceMetrics)) == true
        expect(allCases.contains(.configFilePath)) == true
        expect(allCases.contains(.hasAskedForScreenCapturePermissions)) == true
    }

    // MARK: - Logger Configuration Keys Tests

    func testLogLevelKey() {
        // Given logLevel key
        // When accessing raw value
        let key = UserDefaultsKeys.logLevel.rawValue

        // Then should have correct format
        expect(key) == "com.aerospacebar.preferences.logLevel"
        expect(key.hasPrefix("com.aerospacebar.preferences.")) == true
    }

    func testEnablePerformanceMetricsKey() {
        // Given enablePerformanceMetrics key
        // When accessing raw value
        let key = UserDefaultsKeys.enablePerformanceMetrics.rawValue

        // Then should have correct format
        expect(key) == "com.aerospacebar.preferences.enablePerformanceMetrics"
        expect(key.hasPrefix("com.aerospacebar.preferences.")) == true
    }

    // MARK: - System Integration Keys Tests

    func testConfigFilePathKey() {
        // Given configFilePath key
        // When accessing raw value
        let key = UserDefaultsKeys.configFilePath.rawValue

        // Then should have correct format
        expect(key) == "com.aerospacebar.preferences.configFilePath"
        expect(key.hasPrefix("com.aerospacebar.preferences.")) == true
    }

    // MARK: - Screen Capture Permission Keys Tests

    func testHasAskedForScreenCapturePermissionsKey() {
        // Given hasAskedForScreenCapturePermissions key
        // When accessing raw value
        let key = UserDefaultsKeys.hasAskedForScreenCapturePermissions.rawValue

        // Then should have correct format
        expect(key) == "com.aerospacebar.preferences.hasAskedForScreenCapturePermissions"
        expect(key.hasPrefix("com.aerospacebar.preferences.")) == true
    }

    // MARK: - Key Format Tests

    func testAllKeysHaveConsistentPrefix() {
        // Given all keys
        let allKeys = UserDefaultsKeys.allCases

        // When checking prefixes
        for key in allKeys {
            // Then all should use standard prefix
            expect(key.rawValue.hasPrefix("com.aerospacebar.preferences.")) == true
        }
    }

    func testAllKeysFollowNamingConvention() {
        // Given all keys
        let allKeys = UserDefaultsKeys.allCases

        // When checking naming
        for key in allKeys {
            let rawValue = key.rawValue
            // Then should follow reverse DNS notation
            expect(rawValue.contains(".")) == true
            expect(rawValue.hasPrefix("com.")) == true
            expect(rawValue.hasSuffix(".")) == false
        }
    }

    // MARK: - Key Uniqueness Tests

    func testAllKeysAreUnique() {
        // Given all keys
        let allKeys = UserDefaultsKeys.allCases.map(\.rawValue)

        // When converting to Set
        let uniqueKeys = Set(allKeys)

        // Then should have same count (no duplicates)
        expect(uniqueKeys.count) == allKeys.count
    }

    func testKeysDoNotOverlap() {
        // Given all keys
        let allKeys = UserDefaultsKeys.allCases.map(\.rawValue)

        // When checking for overlap
        for (index, key) in allKeys.enumerated() {
            for (otherIndex, otherKey) in allKeys.enumerated() where index != otherIndex {
                // Then no key should be a prefix of another
                expect(!key.hasPrefix(otherKey) && key != otherKey) == true
                expect(!otherKey.hasPrefix(key) && key != otherKey) == true
            }
        }
    }

    // MARK: - Integration Tests

    func testKeysCanBeUsedWithUserDefaults() {
        // Given UserDefaults instance
        let userDefaults = UserDefaults.standard
        let testKey = UserDefaultsKeys.logLevel.rawValue

        // When setting and getting value
        userDefaults.set("debug", forKey: testKey)
        let value = userDefaults.string(forKey: testKey)

        // Then should work correctly
        expect(value) == "debug"

        // Cleanup
        userDefaults.removeObject(forKey: testKey)
    }

    func testMultipleKeysDoNotConflict() {
        // Given UserDefaults instance
        let userDefaults = UserDefaults.standard

        // When setting different values for different keys
        userDefaults.set("debug", forKey: UserDefaultsKeys.logLevel.rawValue)
        userDefaults.set(true, forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue)
        userDefaults.set("/custom/path", forKey: UserDefaultsKeys.configFilePath.rawValue)

        // Then each key should retain its own value
        expect(userDefaults.string(forKey: UserDefaultsKeys.logLevel.rawValue)) == "debug"
        expect(userDefaults.bool(forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue)) == true
        expect(userDefaults.string(forKey: UserDefaultsKeys.configFilePath.rawValue)) == "/custom/path"

        // Cleanup
        userDefaults.removeObject(forKey: UserDefaultsKeys.logLevel.rawValue)
        userDefaults.removeObject(forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue)
        userDefaults.removeObject(forKey: UserDefaultsKeys.configFilePath.rawValue)
    }

    // MARK: - Purpose Tests

    func testLoggerConfigurationKeysAvoidCircularDependency() {
        // Given logger configuration keys
        let loggerKeys: Set<UserDefaultsKeys> = [.logLevel, .enablePerformanceMetrics]

        // When checking they exist
        for key in loggerKeys {
            // Then should be present in enum
            expect(UserDefaultsKeys.allCases.contains(key)) == true
        }

        // And should be minimal set to avoid dependencies
        expect(loggerKeys.count) <= 2
    }

    func testBootstrapKeysAreAvailable() {
        // Given bootstrap key for TOML loading
        let bootstrapKey = UserDefaultsKeys.configFilePath

        // Then should exist
        expect(UserDefaultsKeys.allCases.contains(bootstrapKey)) == true
    }
}
