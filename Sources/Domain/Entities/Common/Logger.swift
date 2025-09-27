// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
import os.log
import os.signpost

/// Enhanced centralized logging system for AeroSpaceBar.
///
/// This system provides:
/// - Runtime log level control
/// - Privacy redaction for sensitive data
/// - Performance metrics tracking with signposts
/// - Centralized configuration
/// - Structured logging with metadata
public enum Logger {
    // MARK: - Log Levels

    /// Represents different log levels with their corresponding OSLog types
    public enum Level: String, CaseIterable, Sendable {
        case debug
        case info
        case warning
        case error
        case fault

        var osLogType: OSLogType {
            switch self {
            case .debug: .debug
            case .info: .info
            case .warning: .error
            case .error: .error
            case .fault: .fault
            }
        }

        var name: String {
            switch self {
            case .debug: "DEBUG"
            case .info: "INFO"
            case .warning: "️WARNING"
            case .error: "ERROR"
            case .fault: "FAULT"
            }
        }

        /// Numeric priority for level comparison (higher = more important)
        var priority: Int {
            switch self {
            case .debug: 0
            case .info: 1
            case .warning: 2
            case .error: 3
            case .fault: 4
            }
        }
    }

    // MARK: - Configuration

    /// Global log level configuration (persisted in UserDefaults)
    /// Current log level. Can be changed at runtime.
    public static var logLevel: Level {
        get {
            if
                let savedLevel = UserDefaults.standard.string(forKey: UserDefaultsKeys.logLevel.rawValue),
                let level = Level(rawValue: savedLevel)
            {
                return level
            }
            return .info
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaultsKeys.logLevel.rawValue)
            info("Log level changed to: \(newValue.rawValue)", category: Logger.app)
        }
    }

    /// Whether to enable performance metrics
    static var enablePerformanceMetrics: Bool {
        get { UserDefaults.standard.bool(forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue) }
    }

    // MARK: - Log Categories

    /// Log category for application lifecycle events.
    public static let app = OSLog(subsystem: "com.rdrkr.AeroSpaceBar", category: "app")

    /// Log category for AeroSpace CLI operations.
    public static let aerospace = OSLog(subsystem: "com.rdrkr.AeroSpaceBar", category: "aerospace")

    /// Log category for spaces and windows management.
    public static let spaces = OSLog(subsystem: "com.rdrkr.AeroSpaceBar", category: "spaces")

    /// Log category for configuration and settings.
    public static let config = OSLog(subsystem: "com.rdrkr.AeroSpaceBar", category: "config")

    /// Log category for UI and presentation layer.
    public static let userInterface = OSLog(subsystem: "com.rdrkr.AeroSpaceBar", category: "ui")

    /// Log category for data layer operations.
    public static let data = OSLog(subsystem: "com.rdrkr.AeroSpaceBar", category: "data")

    /// Log category for performance metrics.
    public static let performance = OSLog(subsystem: "com.rdrkr.AeroSpaceBar", category: "performance")

    // MARK: - Signpost IDs for Performance Tracking

    private static let signposter = OSSignposter(logHandle: performance)

    /// Signpost IDs for different operations
    public enum SignpostID {
        public static let spacesFetch = signposter.makeSignpostID()
        public static let windowFocus = signposter.makeSignpostID()
        public static let spaceFocus = signposter.makeSignpostID()
        public static let iconLoad = signposter.makeSignpostID()
        public static let wallpaperLoad = signposter.makeSignpostID()
        public static let cliOperation = signposter.makeSignpostID()
    }

    // MARK: - Privacy Redaction

    /// Redacts sensitive information from log messages
    private static func redactSensitiveData(_ message: String) -> String {
        var redactedMessage = message

        // Redact file paths that might contain user information
        let pathPattern = #"\/Users\/[^\/]+\/"#
        redactedMessage = redactedMessage.replacingOccurrences(
            of: pathPattern,
            with: "/Users/***/",
            options: .regularExpression
        )

        // Redact potential API keys or tokens
        let tokenPattern = #"[a-zA-Z0-9]{32,}"#
        redactedMessage = redactedMessage.replacingOccurrences(
            of: tokenPattern,
            with: "***REDACTED***",
            options: .regularExpression
        )

        return redactedMessage
    }

    // MARK: - Core Logging Methods

    /// Internal logging method that handles level checking and formatting
    private static func log(
        _ level: Level,
        _ message: String,
        category: OSLog = app,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        // Check if we should log at this level
        guard level.priority >= logLevel.priority else { return }

        let fileName = URL(fileURLWithPath: file).lastPathComponent
        var logMessage = "[\(level.name)] [\(fileName):\(line) \(function)]: \(message)"

        // Add metadata if provided
        if let metadata, !metadata.isEmpty {
            let metadataString = metadata.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            logMessage += " | Metadata: {\(metadataString)}"
        }

        // Apply privacy redaction
        #if !DEBUG
            logMessage = redactSensitiveData(logMessage)
        #endif

        #if DEBUG
            print(logMessage)
        #endif

        unsafe os_log(level.osLogType, log: category, "%{public}@", logMessage)
    }

    // MARK: - Public Logging Interface

    /// Logs a debug message.
    public static func debug(
        _ message: String,
        category: OSLog = app,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(.debug, message, category: category, metadata: metadata, file: file, function: function, line: line)
    }

    /// Logs an info message.
    public static func info(
        _ message: String,
        category: OSLog = app,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(.info, message, category: category, metadata: metadata, file: file, function: function, line: line)
    }

    /// Logs a warning message.
    public static func warning(
        _ message: String,
        category: OSLog = app,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(.warning, message, category: category, metadata: metadata, file: file, function: function, line: line)
    }

    /// Logs an error message.
    public static func error(
        _ message: String,
        category: OSLog = app,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(.error, message, category: category, metadata: metadata, file: file, function: function, line: line)
    }

    /// Logs an error with an associated error object.
    public static func error(
        _ message: String,
        error: Error,
        category: OSLog = app,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var errorMetadata = metadata ?? [:]
        errorMetadata["error"] = error.localizedDescription
        errorMetadata["errorType"] = String(describing: type(of: error))

        log(.error, message, category: category, metadata: errorMetadata, file: file, function: function, line: line)
    }

    /// Logs a fault message (critical error).
    public static func fault(
        _ message: String,
        category: OSLog = app,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(.fault, message, category: category, metadata: metadata, file: file, function: function, line: line)
    }

    // MARK: - Performance Metrics

    /// Starts a performance measurement interval
    public static func beginInterval(_ name: String, id _: OSSignpostID) {
        guard enablePerformanceMetrics else { return }

        // For now, just log the start of the interval
        debug("Performance interval started: \(name)", category: Logger.performance)
    }

    /// Ends a performance measurement interval
    public static func endInterval(_ name: String, id _: OSSignpostID) {
        guard enablePerformanceMetrics else { return }

        // For now, just log the end of the interval
        debug("Performance interval ended: \(name)", category: Logger.performance)
    }

    /// Measures the execution time of a block
    public static func measure<T>(
        _ name: String,
        id _: OSSignpostID,
        operation: @Sendable () throws -> T
    ) rethrows -> T {
        guard enablePerformanceMetrics else { return try operation() }

        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let endTime = CFAbsoluteTimeGetCurrent()
            let duration = endTime - startTime
            info(unsafe "Performance: \(name) took \(String(format: "%.3f", duration))s", category: Logger.performance)
        }

        return try operation()
    }

    /// Measures the execution time of an async block
    public static func measure<T>(
        _ name: String,
        id _: OSSignpostID,
        operation: @Sendable () async throws -> T
    ) async rethrows -> T {
        guard enablePerformanceMetrics else { return try await operation() }

        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let endTime = CFAbsoluteTimeGetCurrent()
            let duration = endTime - startTime
            info(unsafe "Performance: \(name) took \(String(format: "%.3f", duration))s", category: Logger.performance)
        }

        return try await operation()
    }
}
