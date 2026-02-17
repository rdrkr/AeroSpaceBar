// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for AdvancedSettings class.
///
/// These tests verify AdvancedSettings with both OptionalMode and RequiredMode,
/// decode() merging logic, and type aliases.
@MainActor
final class AdvancedSettingsTests: XCTestCase {
    // MARK: - RequiredMode Initialization Tests

    func testRequiredModeInitialization() {
        // Given required mode parameters
        let focusWindowOnClick = true
        let enablePerformanceMetrics = false
        let isOptimizedPerformanceEnabled = true
        let logLevel = "debug"

        // When creating required settings
        let settings = AdvancedSettings<RequiredMode>(
            focusWindowOnClick: focusWindowOnClick,
            enablePerformanceMetrics: enablePerformanceMetrics,
            isOptimizedPerformanceEnabled: isOptimizedPerformanceEnabled,
            logLevel: logLevel
        )

        // Then all properties should be set
        expect(settings.focusWindowOnClick) == focusWindowOnClick
        expect(settings.enablePerformanceMetrics) == enablePerformanceMetrics
        expect(settings.isOptimizedPerformanceEnabled) == isOptimizedPerformanceEnabled
        expect(settings.logLevel) == logLevel
    }

    // MARK: - OptionalMode Initialization Tests

    func testOptionalModeInitializationWithValues() {
        // Given optional mode parameters
        let focusWindowOnClick: Bool? = true
        let enablePerformanceMetrics: Bool? = false
        let isOptimizedPerformanceEnabled: Bool? = true
        let logLevel: String? = "info"

        // When creating optional settings
        let settings = AdvancedSettings<OptionalMode>(
            focusWindowOnClick: focusWindowOnClick,
            enablePerformanceMetrics: enablePerformanceMetrics,
            isOptimizedPerformanceEnabled: isOptimizedPerformanceEnabled,
            logLevel: logLevel
        )

        // Then all properties should be set
        expect(settings.focusWindowOnClick) == focusWindowOnClick
        expect(settings.enablePerformanceMetrics) == enablePerformanceMetrics
        expect(settings.isOptimizedPerformanceEnabled) == isOptimizedPerformanceEnabled
        expect(settings.logLevel) == logLevel
    }

    func testOptionalModeInitializationWithNils() {
        // Given optional mode with nil values
        let settings = AdvancedSettings<OptionalMode>(
            focusWindowOnClick: nil,
            enablePerformanceMetrics: nil,
            isOptimizedPerformanceEnabled: nil,
            logLevel: nil
        )

        // Then all properties should be nil
        expect(settings.focusWindowOnClick).to(beNil())
        expect(settings.enablePerformanceMetrics).to(beNil())
        expect(settings.isOptimizedPerformanceEnabled).to(beNil())
        expect(settings.logLevel).to(beNil())
    }

    // MARK: - Decode Method Tests

    func testDecodeWithAllOptionalValuesNil() throws {
        // Given optional settings with all nil values
        let optional = AdvancedSettings<OptionalMode>(
            focusWindowOnClick: nil,
            enablePerformanceMetrics: nil,
            isOptimizedPerformanceEnabled: nil,
            logLevel: nil
        )

        // And default settings
        let defaultSettings = AdvancedSettings<RequiredMode>(
            focusWindowOnClick: false,
            enablePerformanceMetrics: false,
            isOptimizedPerformanceEnabled: false,
            logLevel: "warning"
        )

        // When decoding
        let decoded = try AdvancedSettings<RequiredMode>.decode(from: optional, defaultValue: defaultSettings)

        // Then should use all default values
        expect(decoded.focusWindowOnClick) == defaultSettings.focusWindowOnClick
        expect(decoded.enablePerformanceMetrics) == defaultSettings.enablePerformanceMetrics
        expect(decoded.isOptimizedPerformanceEnabled) == defaultSettings.isOptimizedPerformanceEnabled
        expect(decoded.logLevel) == defaultSettings.logLevel
    }

    func testDecodeWithAllOptionalValuesSet() throws {
        // Given optional settings with all values set
        let optional = AdvancedSettings<OptionalMode>(
            focusWindowOnClick: true,
            enablePerformanceMetrics: true,
            isOptimizedPerformanceEnabled: true,
            logLevel: "debug"
        )

        // And default settings (different values)
        let defaultSettings = AdvancedSettings<RequiredMode>(
            focusWindowOnClick: false,
            enablePerformanceMetrics: false,
            isOptimizedPerformanceEnabled: false,
            logLevel: "error"
        )

        // When decoding
        let decoded = try AdvancedSettings<RequiredMode>.decode(from: optional, defaultValue: defaultSettings)

        // Then should use all optional values
        expect(decoded.focusWindowOnClick) == true
        expect(decoded.enablePerformanceMetrics) == true
        expect(decoded.isOptimizedPerformanceEnabled) == true
        expect(decoded.logLevel) == "debug"
    }

    func testDecodeWithMixedOptionalValues() throws {
        // Given optional settings with mixed values
        let optional = AdvancedSettings<OptionalMode>(
            focusWindowOnClick: true,
            enablePerformanceMetrics: nil, // Will use default
            isOptimizedPerformanceEnabled: false,
            logLevel: nil // Will use default
        )

        // And default settings
        let defaultSettings = AdvancedSettings<RequiredMode>(
            focusWindowOnClick: false,
            enablePerformanceMetrics: true,
            isOptimizedPerformanceEnabled: true,
            logLevel: "info"
        )

        // When decoding
        let decoded = try AdvancedSettings<RequiredMode>.decode(from: optional, defaultValue: defaultSettings)

        // Then should merge correctly
        expect(decoded.focusWindowOnClick) == true
        expect(decoded.enablePerformanceMetrics) == true
        expect(decoded.isOptimizedPerformanceEnabled) == false
        expect(decoded.logLevel) == "info"
    }

    // MARK: - Log Level Tests

    func testAllLogLevelsSupported() {
        // Given all log level strings
        let logLevels = ["debug", "info", "warning", "error", "fault"]

        for level in logLevels {
            // When creating settings with each log level
            let settings = AdvancedSettings<RequiredMode>(
                focusWindowOnClick: true,
                enablePerformanceMetrics: true,
                isOptimizedPerformanceEnabled: false,
                logLevel: level
            )

            // Then should accept the log level
            expect(settings.logLevel) == level
        }
    }

    // MARK: - Performance Settings Tests

    func testPerformanceOptimizationCombinations() {
        // Given various performance setting combinations
        let combinations: [(Bool, Bool)] = [
            (true, true), // Both enabled
            (true, false), // Only metrics
            (false, true), // Only optimization
            (false, false) // Both disabled
        ]

        for (metrics, optimization) in combinations {
            // When creating settings with each combination
            let settings = AdvancedSettings<RequiredMode>(
                focusWindowOnClick: true,
                enablePerformanceMetrics: metrics,
                isOptimizedPerformanceEnabled: optimization,
                logLevel: "info"
            )

            // Then should accept the combination
            expect(settings.enablePerformanceMetrics) == metrics
            expect(settings.isOptimizedPerformanceEnabled) == optimization
        }
    }

    // MARK: - Type Alias Tests

    func testOptionalVariantTypeAlias() {
        // Given OptionalVariant type alias
        let settings: AdvancedSettings<RequiredMode>.OptionalVariant = AdvancedSettings<OptionalMode>(
            focusWindowOnClick: nil,
            enablePerformanceMetrics: nil,
            isOptimizedPerformanceEnabled: nil,
            logLevel: nil
        )

        // Then should be correct type
        expect(String(describing: type(of: settings))) == String(describing: AdvancedSettings<OptionalMode>.self)
    }

    func testRequiredVariantTypeAlias() {
        // Given RequiredVariant type alias
        let settings: AdvancedSettings<OptionalMode>.RequiredVariant = AdvancedSettings<RequiredMode>(
            focusWindowOnClick: false,
            enablePerformanceMetrics: false,
            isOptimizedPerformanceEnabled: false,
            logLevel: "info"
        )

        // Then should be correct type
        expect(String(describing: type(of: settings))) == String(describing: AdvancedSettings<RequiredMode>.self)
    }

    // MARK: - Edge Cases

    func testEmptyLogLevel() {
        // Given empty log level
        let settings = AdvancedSettings<RequiredMode>(
            focusWindowOnClick: true,
            enablePerformanceMetrics: true,
            isOptimizedPerformanceEnabled: false,
            logLevel: ""
        )

        // Then should accept empty string
        expect(settings.logLevel.isEmpty) == true
    }

    func testCustomLogLevel() {
        // Given custom log level string
        let customLevel = "custom-level-123"
        let settings = AdvancedSettings<RequiredMode>(
            focusWindowOnClick: true,
            enablePerformanceMetrics: true,
            isOptimizedPerformanceEnabled: false,
            logLevel: customLevel
        )

        // Then should accept custom string
        expect(settings.logLevel) == customLevel
    }

    // MARK: - Integration Scenarios

    func testDevelopmentConfiguration() {
        // Given development-oriented settings
        let settings = AdvancedSettings<RequiredMode>(
            focusWindowOnClick: true,
            enablePerformanceMetrics: true,
            isOptimizedPerformanceEnabled: false,
            logLevel: "debug"
        )

        // Then should have debug configuration
        expect(settings.enablePerformanceMetrics) == true
        expect(settings.logLevel) == "debug"
        expect(settings.isOptimizedPerformanceEnabled) == false
    }

    func testProductionConfiguration() {
        // Given production-oriented settings
        let settings = AdvancedSettings<RequiredMode>(
            focusWindowOnClick: true,
            enablePerformanceMetrics: false,
            isOptimizedPerformanceEnabled: true,
            logLevel: "error"
        )

        // Then should have production configuration
        expect(settings.enablePerformanceMetrics) == false
        expect(settings.logLevel) == "error"
        expect(settings.isOptimizedPerformanceEnabled) == true
    }
}
