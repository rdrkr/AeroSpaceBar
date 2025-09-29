// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Advanced settings including performance and debugging options with generic optionality support.
///
/// This structure manages advanced configuration options like performance metrics,
/// logging levels, and interaction behaviors. Supports both optional and required field variants.
/// Uses the `OptionalTypeMapping` protocol to provide type-level optionality control,
/// allowing the same structure to represent both optional TOML configuration data
/// and required runtime configuration with proper default value merging.
public class AdvancedSettings<Mode: OptionalTypeMapping>: OptionalType
    where Mode.BoolType: Codable, Mode.StringType: Codable
{
    /// Type alias for the optional variant used during TOML decoding.
    public typealias OptionalVariant = AdvancedSettings<OptionalMode>

    /// Type alias for the required variant used during runtime operations.
    public typealias RequiredVariant = AdvancedSettings<RequiredMode>

    /// Whether to focus windows when clicked in the menu bar interface.
    ///
    /// When enabled, clicking on a window representation in the menu bar will
    /// focus that window and bring it to the foreground.
    public let focusWindowOnClick: Mode.BoolType

    /// Whether to enable performance metrics collection and logging.
    ///
    /// When enabled, the application will collect and log performance metrics
    /// for monitoring application responsiveness and resource usage.
    public let enablePerformanceMetrics: Mode.BoolType

    /// Whether to enable optimized performance mode.
    ///
    /// When enabled, the application uses performance optimizations that may
    /// reduce feature richness but improve responsiveness, especially useful
    /// for systems with many windows or spaces.
    public let isOptimizedPerformanceEnabled: Mode.BoolType

    /// The current log level for application logging (raw string value).
    ///
    /// Controls the verbosity of application logging. Valid values correspond
    /// to `Logger.Level` enum cases (e.g., "debug", "info", "warning", "error").
    public let logLevel: Mode.StringType

    /// Initializes a new AdvancedSettings instance.
    ///
    /// - Parameters:
    ///   - focusWindowOnClick: Whether to focus windows when clicked in the menu bar
    ///   - enablePerformanceMetrics: Whether to enable performance metrics collection
    ///   - isOptimizedPerformanceEnabled: Whether to enable optimized performance mode
    ///   - logLevel: The log level for application logging (raw string value)
    public init(
        focusWindowOnClick: Mode.BoolType,
        enablePerformanceMetrics: Mode.BoolType,
        isOptimizedPerformanceEnabled: Mode.BoolType,
        logLevel: Mode.StringType
    ) {
        self.focusWindowOnClick = focusWindowOnClick
        self.enablePerformanceMetrics = enablePerformanceMetrics
        self.isOptimizedPerformanceEnabled = isOptimizedPerformanceEnabled
        self.logLevel = logLevel
    }

    enum CodingKeys: String, CodingKey {
        case focusWindowOnClick = "focus-window-on-click"
        case enablePerformanceMetrics = "enable-performance-metrics"
        case isOptimizedPerformanceEnabled = "enable-optimized-performance"
        case logLevel = "log-level"
    }

    /// Decodes optional settings and merges with required defaults.
    ///
    /// This method implements the `OptionalType` protocol requirement, providing
    /// a way to merge optional TOML configuration data with required default values.
    /// For each property, if the decoded value is nil, the corresponding default value is used.
    ///
    /// - Parameters:
    ///   - decodedValue: The optional settings decoded from TOML configuration
    ///   - defaultValue: The required default settings to use for nil values
    /// - Returns: A new `AdvancedSettings<RequiredMode>` instance with merged values
    /// - Throws: Can throw decoding errors if the merge operation fails
    public static func decode(
        from decodedValue: AdvancedSettings<OptionalMode>,
        defaultValue: AdvancedSettings<RequiredMode>
    ) throws -> AdvancedSettings<RequiredMode> {
        AdvancedSettings<RequiredMode>(
            focusWindowOnClick: decodedValue.focusWindowOnClick ??
                defaultValue.focusWindowOnClick,
            enablePerformanceMetrics: decodedValue.enablePerformanceMetrics ??
                defaultValue.enablePerformanceMetrics,
            isOptimizedPerformanceEnabled: decodedValue.isOptimizedPerformanceEnabled ??
                defaultValue.isOptimizedPerformanceEnabled,
            logLevel: decodedValue.logLevel ?? defaultValue.logLevel
        )
    }
}

public extension OptionalMode {
    typealias AdvancedSettingsType = AdvancedSettings<RequiredMode>?
}

public extension RequiredMode {
    typealias AdvancedSettingsType = AdvancedSettings<RequiredMode>
}
