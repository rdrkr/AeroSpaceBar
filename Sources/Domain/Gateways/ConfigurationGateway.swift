// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import SwiftUI

/// Protocol defining the interface for configuration operations.
///
/// This protocol provides a contract for repositories that manage application configuration,
/// allowing for easy testing and dependency injection. It belongs to the domain layer
/// and defines the business requirements for configuration operations.
/// Following reactive patterns similar to Kotlin Flow/StateFlow.
@MainActor
public protocol ConfigurationGateway {
    // MARK: - Publishers for Reactive Data Flow

    /// Publisher that emits show window titles updates.
    var showWindowTitlesPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits AeroSpace path updates.
    var aeroSpacePathPublisher: AnyPublisher<String, Never> { get }

    /// Publisher that emits focus window on click updates.
    var focusWindowOnClickPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits show empty spaces updates.
    var showEmptySpacesPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits show groups updates.
    var showGroupsPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits enable performance metrics updates.
    var enablePerformanceMetricsPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits optimized performance enabled updates.
    var isOptimizedPerformanceEnabledPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits log level updates.
    var logLevelPublisher: AnyPublisher<Logger.Level, Never> { get }

    /// Publisher that emits AeroSpace version updates.
    var currentAeroSpaceVersionPublisher: AnyPublisher<String?, Never> { get }

    /// Publisher that emits config file path updates.
    var configFilePathPublisher: AnyPublisher<String, Never> { get }

    // MARK: - UI Configuration Publishers

    /// Publisher that emits spaces configuration updates.
    var spacesVisualConfigPublisher: AnyPublisher<[VisualProperties], Never> { get }

    /// Publisher that emits spaces appearance mode updates.
    var spacesAppearanceModePublisher: AnyPublisher<SpacesAppearanceMode, Never> { get }

    /// Publisher that emits global space visual configuration updates.
    var globalSpacesVisualConfigPublisher: AnyPublisher<VisualProperties, Never> { get }

    /// Publisher that emits group configuration updates.
    var groupsPublisher: AnyPublisher<[Domain.Group], Never> { get }

    /// Publisher that emits groups appearance mode updates.
    var groupsAppearanceModePublisher: AnyPublisher<GroupsAppearanceMode, Never> { get }

    /// Publisher that emits global groups visual configuration updates.
    var globalGroupsVisualConfigPublisher: AnyPublisher<VisualProperties, Never> { get }

    // MARK: - Async Setters (trigger updates via publishers)

    func setShowWindowTitles(_ value: Bool) async

    func setAeroSpacePath(_ path: String) async

    func setFocusWindowOnClick(_ value: Bool) async

    func setShowEmptySpaces(_ value: Bool) async

    func setShowGroups(_ value: Bool) async

    func setEnablePerformanceMetrics(_ value: Bool) async

    func setIsOptimizedPerformanceEnabled(_ value: Bool) async

    func setLogLevel(_ level: Logger.Level) async

    func setConfigFilePath(_ path: String) async

    // MARK: - UI Configuration Async Setters

    func setSpacesVisualConfig(_ value: [VisualProperties]) async

    func setSpacesAppearanceMode(_ value: SpacesAppearanceMode) async

    func setGlobalGroupsVisualConfig(_ value: VisualProperties) async

    func setGroups(_ value: [Domain.Group]) async

    func setGroupsAppearanceMode(_ value: GroupsAppearanceMode) async

    func setGlobalSpacesVisualConfig(_ value: VisualProperties) async

    // MARK: - AeroSpace Configuration Management

    func openAeroSpaceConfig() async

    func getAeroSpaceConfigPath() async -> URL

    func getConfigFilePath() -> String

    func openConfigFile() async

    // MARK: - Configuration Management

    /// Resets all configuration settings to their default values.
    func resetToDefaults() async
}
