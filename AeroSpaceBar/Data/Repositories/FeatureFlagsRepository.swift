// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

@preconcurrency import Combine
import Foundation

/// Repository implementation for feature flags with in-memory storage.
///
/// This class provides in-memory storage for feature flags that reset to defaults on each run,
/// with reactive updates through Combine publishers. Only available in debug builds.
#if DEBUG
    final class FeatureFlagsRepository: FeatureFlagsGateway, @unchecked Sendable {
        private let featureFlagsSubject: CurrentValueSubject<FeatureFlags, Never>

        /// Initializes the repository with default feature flags.
        init() {
            // Always start with default feature flags
            let defaultFlags = FeatureFlagDefaults.createDefault()
            featureFlagsSubject = CurrentValueSubject(defaultFlags)
        }

        // MARK: - FeatureFlagsGateway Implementation

        var featureFlags: AnyPublisher<FeatureFlags, Never> {
            featureFlagsSubject.eraseToAnyPublisher()
        }

        func setFeatureFlags(_ flags: FeatureFlags) async {
            await MainActor.run {
                featureFlagsSubject.send(flags)
            }
        }

        func resetToDefaults() async {
            let defaultFlags = FeatureFlagDefaults.createDefault()
            await setFeatureFlags(defaultFlags)
        }
    }
#else
    final class FeatureFlagsRepository: FeatureFlagsGateway, @unchecked Sendable {
        var featureFlags: AnyPublisher<FeatureFlags, Never> {
            Just(FeatureFlagDefaults.createDefault()).eraseToAnyPublisher()
        }

        func setFeatureFlags(_: FeatureFlags) async {
            // No-op in release builds
        }

        func resetToDefaults() async {
            // No-op in release builds
        }
    }
#endif
