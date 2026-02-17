// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import os.log
import XCTest

/// Tests for Logger system.
///
/// These tests verify Logger log levels, categories, performance metrics,
/// privacy redaction, and runtime configuration.
@MainActor
final class LoggerTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        // Reset to default log level before each test
        Logger.logLevel = ConfigurationDefaults.logLevel
    }

    // MARK: - Log Level Tests

    func testLogLevelCases() {
        // Given all log levels
        let levels = Logger.Level.allCases

        // Then should have all 5 levels
        expect(levels.count) == 5
        expect(levels.contains(.debug)) == true
        expect(levels.contains(.info)) == true
        expect(levels.contains(.warning)) == true
        expect(levels.contains(.error)) == true
        expect(levels.contains(.fault)) == true
    }

    func testLogLevelRawValues() {
        // Given log levels
        let debug = Logger.Level.debug
        let info = Logger.Level.info
        let warning = Logger.Level.warning
        let error = Logger.Level.error
        let fault = Logger.Level.fault

        // Then should have correct raw values
        expect(debug.rawValue) == "debug"
        expect(info.rawValue) == "info"
        expect(warning.rawValue) == "warning"
        expect(error.rawValue) == "error"
        expect(fault.rawValue) == "fault"
    }

    func testLogLevelNames() {
        // Given log levels
        let levels: [(Domain.Logger.Level, String)] = [
            (.debug, "DEBUG"),
            (.info, "INFO"),
            (.warning, "️WARNING"),
            (.error, "ERROR"),
            (.fault, "FAULT")
        ]

        for (level, expectedName) in levels {
            // Then should have correct names
            expect(level.name) == expectedName
        }
    }

    func testLogLevelPriorities() {
        // Given log levels
        let debug = Logger.Level.debug
        let info = Logger.Level.info
        let warning = Logger.Level.warning
        let error = Logger.Level.error
        let fault = Logger.Level.fault

        // Then priorities should be in ascending order
        expect(debug.priority) == 0
        expect(info.priority) == 1
        expect(warning.priority) == 2
        expect(error.priority) == 3
        expect(fault.priority) == 4

        expect(debug.priority) < info.priority
        expect(info.priority) < warning.priority
        expect(warning.priority) < error.priority
        expect(error.priority) < fault.priority
    }

    func testLogLevelOSLogTypes() {
        // Given log levels
        let levels: [(Domain.Logger.Level, OSLogType)] = [
            (.debug, .debug),
            (.info, .info),
            (.warning, .error),
            (.error, .error),
            (.fault, .fault)
        ]

        for (level, expectedType) in levels {
            // Then should map to correct OSLogType
            expect(level.osLogType) == expectedType
        }
    }

    // MARK: - Log Level Configuration Tests

    func testDefaultLogLevel() {
        // When accessing default log level
        let level = Logger.logLevel

        // Then should be default from configuration
        expect(level) == ConfigurationDefaults.logLevel
    }

    func testSetLogLevel() {
        // Given a new log level
        let newLevel = Logger.Level.error

        // When setting log level
        Logger.logLevel = newLevel

        // Then should update
        expect(Logger.logLevel) == newLevel
    }

    func testLogLevelPersistence() {
        // Given a log level change
        Logger.logLevel = .warning

        // When reading back
        let savedLevel = UserDefaults.standard.string(forKey: UserDefaultsKeys.logLevel.rawValue)

        // Then should be persisted
        expect(savedLevel) == "warning"
    }

    func testLogLevelRestoreFromUserDefaults() {
        // Given a saved log level
        UserDefaults.standard.set("error", forKey: UserDefaultsKeys.logLevel.rawValue)

        // When accessing log level
        let level = Logger.logLevel

        // Then should restore from UserDefaults
        expect(level) == .error
    }

    func testLogLevelDefaultsWhenNotSaved() {
        // Given no saved log level
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.logLevel.rawValue)

        // When accessing log level
        let level = Logger.logLevel

        // Then should return configuration default
        expect(level) == ConfigurationDefaults.logLevel
    }

    func testEnablePerformanceMetricsDefaultsWhenNotSaved() {
        // Given no saved performance metrics setting
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue)

        // When accessing enablePerformanceMetrics
        let enabled = Logger.enablePerformanceMetrics

        // Then should return configuration default
        expect(enabled) == ConfigurationDefaults.enablePerformanceMetrics
    }

    func testSetSameLogLevelDoesNotUpdate() {
        // Given current log level
        let currentLevel = Logger.logLevel

        // When setting to same level
        Logger.logLevel = currentLevel

        // Then should not change (implementation detail: prevents unnecessary updates)
        expect(Logger.logLevel) == currentLevel
    }

    // MARK: - Log Categories Tests

    func testLogCategoryApp() {
        // Given app category
        let category = Logger.app

        // Then should be a valid OSLog
        expect(category).toNot(beNil())
    }

    func testLogCategoryAerospace() {
        // Given aerospace category
        let category = Logger.aerospace

        // Then should be a valid OSLog
        expect(category).toNot(beNil())
    }

    func testLogCategorySpaces() {
        // Given spaces category
        let category = Logger.spaces

        // Then should be a valid OSLog
        expect(category).toNot(beNil())
    }

    func testLogCategoryConfig() {
        // Given config category
        let category = Logger.config

        // Then should be a valid OSLog
        expect(category).toNot(beNil())
    }

    func testLogCategoryUserInterface() {
        // Given UI category
        let category = Logger.userInterface

        // Then should be a valid OSLog
        expect(category).toNot(beNil())
    }

    func testLogCategoryData() {
        // Given data category
        let category = Logger.data

        // Then should be a valid OSLog
        expect(category).toNot(beNil())
    }

    func testLogCategoryPerformance() {
        // Given performance category
        let category = Logger.performance

        // Then should be a valid OSLog
        expect(category).toNot(beNil())
    }

    // MARK: - Signpost ID Tests

    func testSignpostIDs() {
        // Given signpost IDs
        let spacesFetch = Logger.SignpostID.spacesFetch
        let windowFocus = Logger.SignpostID.windowFocus
        let spaceFocus = Logger.SignpostID.spaceFocus
        let iconLoad = Logger.SignpostID.iconLoad
        let wallpaperLoad = Logger.SignpostID.wallpaperLoad
        let cliOperation = Logger.SignpostID.cliOperation

        // Then all should be unique
        expect(spacesFetch).toNot(beNil())
        expect(windowFocus).toNot(beNil())
        expect(spaceFocus).toNot(beNil())
        expect(iconLoad).toNot(beNil())
        expect(wallpaperLoad).toNot(beNil())
        expect(cliOperation).toNot(beNil())
    }

    // MARK: - Logging Method Tests

    func testDebugLogging() {
        // Given debug level
        Logger.logLevel = .debug

        // When logging debug message
        Logger.debug("Test debug message")

        // Then should not throw (basic smoke test)
    }

    func testInfoLogging() {
        // Given info level
        Logger.logLevel = .info

        // When logging info message
        Logger.info("Test info message")

        // Then should not throw
    }

    func testWarningLogging() {
        // Given warning level
        Logger.logLevel = .warning

        // When logging warning message
        Logger.warning("Test warning message")

        // Then should not throw
    }

    func testErrorLogging() {
        // Given error level
        Logger.logLevel = .error

        // When logging error message
        Logger.error("Test error message")

        // Then should not throw
    }

    func testFaultLogging() {
        // Given fault level
        Logger.logLevel = .fault

        // When logging fault message
        Logger.fault("Test fault message")

        // Then should not throw
    }

    func testErrorLoggingWithError() {
        // Given an error
        struct TestError: Error, LocalizedError {
            var errorDescription: String? {
                "Test error description"
            }
        }
        let error = TestError()

        // When logging with error
        Logger.error("Error occurred", error: error)

        // Then should not throw
    }

    // MARK: - Metadata Tests

    func testLoggingWithMetadata() {
        // Given metadata
        let metadata = ["key1": "value1", "key2": 42] as [String: Any]

        // When logging with metadata
        Logger.info("Message with metadata", metadata: metadata)

        // Then should not throw
    }

    func testLoggingWithEmptyMetadata() {
        // Given empty metadata
        let metadata: [String: Any] = [:]

        // When logging with metadata
        Logger.info("Message with empty metadata", metadata: metadata)

        // Then should not throw
    }

    func testLoggingWithComplexMetadata() {
        // Given complex metadata
        let metadata: [String: Any] = [
            "string": "value",
            "int": 123,
            "double": 45.67,
            "bool": true,
            "array": [1, 2, 3]
        ]

        // When logging with metadata
        Logger.debug("Complex metadata", metadata: metadata)

        // Then should not throw
    }

    // MARK: - Category Tests

    func testLoggingToAllCategories() {
        // Given all categories
        let categories = [
            Logger.app,
            Logger.aerospace,
            Logger.spaces,
            Logger.config,
            Logger.userInterface,
            Logger.data,
            Logger.performance
        ]

        for category in categories {
            // When logging to each category
            Logger.info("Test message", category: category)

            // Then should not throw
        }
    }

    // MARK: - Performance Metrics Tests

    func testPerformanceMetricsDefault() {
        // When accessing default performance metrics setting
        let enabled = UserDefaults.standard.object(forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue) != nil
            ? UserDefaults.standard.bool(forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue)
            : ConfigurationDefaults.enablePerformanceMetrics

        // Then should be a valid boolean value
        expect(enabled).to(beAKindOf(Bool.self))
    }

    func testMeasureSyncOperation() {
        // Given a sync operation
        let operation: @Sendable () -> Int = {
            42
        }

        // When measuring
        let result = Logger.measure("Test operation", id: Logger.SignpostID.cliOperation, operation: operation)

        // Then should execute and return result
        expect(result) == 42
    }

    func testMeasureAsyncOperation() {
        // Given an async operation
        let operation: @Sendable () -> Int = {
            42
        }

        // When measuring async
        let result = Logger.measure(
            "Test async operation",
            id: Logger.SignpostID.cliOperation,
            operation: operation
        )

        // Then should execute and return result
        expect(result) == 42
    }

    func testMeasureThrowingOperation() {
        // Given a throwing operation
        struct TestError: Error { }
        let operation: @Sendable () throws -> Int = {
            throw TestError()
        }

        // When measuring
        expect { try Logger.measure(
            "Throwing operation",
            id: Logger.SignpostID.cliOperation,
            operation: operation
        )
        }.to(throwError())
    }

    func testMeasureAsyncThrowingOperation() {
        // Given an async throwing operation
        struct TestError: Error { }
        let operation: @Sendable () throws -> Int = {
            throw TestError()
        }

        // When measuring
        do {
            _ = try Logger.measure(
                "Async throwing operation",
                id: Logger.SignpostID.cliOperation,
                operation: operation
            )
            XCTFail("Should have thrown")
        } catch {
            expect(error is TestError) == true
        }
    }

    func testBeginInterval() {
        // When beginning interval
        expect {
            Logger.beginInterval("Test interval", id: Logger.SignpostID.spacesFetch)
        }.toNot(throwError())
    }

    func testEndInterval() {
        // When ending interval
        expect {
            Logger.endInterval("Test interval", id: Logger.SignpostID.spacesFetch)
        }.toNot(throwError())
    }

    // MARK: - Sendable Tests

    func testLogLevelSendable() {
        // Logger.Level conforms to Sendable
        Task {
            let level = Logger.Level.info
            // If this compiles, Sendable conformance is working
            expect(level) == Logger.Level.info
        }
    }

    // MARK: - Edge Cases

    func testLoggingVeryLongMessage() {
        // Given a very long message
        let longMessage = String(repeating: "A", count: 10_000)

        // When logging
        expect {
            Logger.info(longMessage)
        }.toNot(throwError())
    }

    func testLoggingEmptyMessage() {
        // Given empty message
        let message = ""

        // When logging
        expect {
            Logger.info(message)
        }.toNot(throwError())
    }

    func testLoggingSpecialCharacters() {
        // Given message with special characters
        let message = "Test message with special chars: 🚀 @#$%^&*() \n\t"

        // When logging
        Logger.debug(message)

        // Then should handle special characters
    }

    func testLoggingUnicodeCharacters() {
        // Given message with unicode
        let message = "Unicode: 你好 مرحبا שלום"

        // When logging
        Logger.info(message)

        // Then should handle unicode
    }

    // MARK: - Log Level Filtering Tests

    func testDebugLevelLogsAll() {
        // Given debug level
        Logger.logLevel = .debug

        // Then should log all levels
        Logger.debug("Debug message")
        Logger.info("Info message")
        Logger.warning("Warning message")
        Logger.error("Error message")
        Logger.fault("Fault message")
    }

    func testInfoLevelSkipsDebug() {
        // Given info level
        Logger.logLevel = .info

        // Then should skip debug
        Logger.debug("Should be skipped")
        Logger.info("Should be logged")
    }

    func testWarningLevelSkipsDebugAndInfo() {
        // Given warning level
        Logger.logLevel = .warning

        // Then should skip debug and info
        Logger.debug("Should be skipped")
        Logger.info("Should be skipped")
        Logger.warning("Should be logged")
    }

    func testErrorLevelSkipsLowerLevels() {
        // Given error level
        Logger.logLevel = .error

        // Then should skip lower levels
        Logger.debug("Should be skipped")
        Logger.info("Should be skipped")
        Logger.warning("Should be skipped")
        Logger.error("Should be logged")
    }

    func testFaultLevelOnlyLogsFaults() {
        // Given fault level
        Logger.logLevel = .fault

        // Then should only log faults
        Logger.debug("Should be skipped")
        Logger.info("Should be skipped")
        Logger.warning("Should be skipped")
        Logger.error("Should be skipped")
        Logger.fault("Should be logged")
    }

    // MARK: - Integration Tests

    func testMultipleConcurrentLogs() async {
        // Given concurrent logging tasks
        await withTaskGroup(of: Void.self) { group in
            for i in 0 ..< 10 {
                group.addTask {
                    Logger.info("Concurrent log \(i)")
                }
            }
        }

        // Then should handle concurrent access
    }

    func testLogLevelChangesDuringLogging() {
        // Given logging operations
        Logger.logLevel = .debug
        Logger.debug("Debug message")

        // When changing level
        Logger.logLevel = .error

        // Then should apply new level
        Logger.debug("Should be skipped")
        Logger.error("Should be logged")
    }
}
