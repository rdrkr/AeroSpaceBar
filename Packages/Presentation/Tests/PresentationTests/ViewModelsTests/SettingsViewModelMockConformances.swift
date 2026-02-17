// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation
@testable import Presentation

// MARK: - Protocol Conformances

// Note: Extensions commented out because final classes cannot be extended
// Tests need to be refactored to use composition instead of inheritance

// extension MockPublisherUseCase: GetMenuBarAppsUseCase where T == [MenuBarApp] { }
// extension MockPublisherUseCase: GetScreenCapturePermissionGrantedUseCase where T == Bool { }
// extension MockAsyncVoidUseCase: RequestScreenCapturePermissionsUseCase { }
// extension MockPublisherUseCase: GetAeroSpacePathUseCase where T == String { }
// extension MockAsyncUseCase: SetAeroSpacePathUseCase where T == String { }
// extension MockPublisherUseCase: GetAeroSpaceVersionUseCase where T == String? { }
// extension MockAsyncVoidUseCase: OpenAeroSpaceConfigUseCase { }
// extension MockAsyncVoidUseCase: ResetConfigurationUseCase { }
// extension MockPublisherUseCase: GetLogLevelUseCase where T == Logger.Level { }
// extension MockAsyncUseCase: SetLogLevelUseCase where T == Logger.Level { }
// extension MockPublisherUseCase: GetEnablePerformanceMetricsUseCase where T == Bool { }
// extension MockAsyncUseCase: SetEnablePerformanceMetricsUseCase where T == Bool { }
// extension MockPublisherUseCase: GetOptimizedPerformanceEnabledUseCase where T == Bool { }
// extension MockAsyncUseCase: SetOptimizedPerformanceEnabledUseCase where T == Bool { }
// extension MockPublisherUseCase: GetFeatureFlagsUseCase where T == FeatureFlags { }
// extension MockPublisherUseCase: GetEnableLicensingUseCase where T == Bool { }
// extension MockPublisherUseCase: GetEnableTrialRequestUseCase where T == Bool { }
// extension MockPublisherUseCase: GetConfigFilePathUseCase where T == String { }
// extension MockAsyncUseCase: SetConfigFilePathUseCase where T == String { }
// extension MockAsyncVoidUseCase: OpenConfigFileUseCase { }
// extension MockPublisherUseCase: GetThemeModeUseCase where T == ThemeMode { }
// extension MockAsyncUseCase: SetThemeModeUseCase where T == ThemeMode { }
// extension MockPublisherUseCase: GetThemePresetColorPropertiesUseCase where T == ThemePresetColorProperties { }
// extension MockAsyncUseCase: SetThemePresetColorPropertiesUseCase where T == ThemePresetColorProperties { }
// extension MockPublisherUseCase: GetAutomaticCheckForUpdatesEnabledUseCase where T == Bool { }
// extension MockAsyncUseCase: SetAutomaticCheckForUpdatesEnabledUseCase where T == Bool {
//     func execute(enabled: Bool) async { await execute(value: enabled) }
// }

// extension MockPublisherUseCase: GetAutomaticDownloadUpdatesEnabledUseCase where T == Bool { }
// extension MockAsyncUseCase: SetAutomaticDownloadUpdatesEnabledUseCase where T == Bool {
//     func execute(enabled: Bool) async { await execute(value: enabled) }
// }

// extension MockPublisherUseCase: GetLastUpdateCheckDateUseCase where T == Date? { }
// extension MockAsyncVoidUseCase: CheckForUpdatesUseCase { }
