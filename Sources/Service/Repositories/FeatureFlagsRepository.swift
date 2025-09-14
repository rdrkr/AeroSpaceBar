// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation

/// Repository implementation for feature flags with in-memory storage.
///
/// This class provides in-memory storage for feature flags that reset to defaults on each run,
/// with reactive updates through Combine publishers. Only available in debug builds.
#if DEBUG
    public final class FeatureFlagsRepository: FeatureFlagsGateway, @unchecked Sendable {
        private let featureFlagsSubject: CurrentValueSubject<FeatureFlags, Never>

        /// Initializes the repository with default feature flags.
        public init() {
            // Always start with default feature flags
            let defaultFlags = FeatureFlagDefaults.createDefault()
            featureFlagsSubject = CurrentValueSubject(defaultFlags)
        }

        // MARK: - FeatureFlagsGateway Implementation

        public var featureFlags: AnyPublisher<FeatureFlags, Never> {
            featureFlagsSubject.eraseToAnyPublisher()
        }

        public var currentFeatureFlags: FeatureFlags {
            featureFlagsSubject.value
        }

        public func setFeatureFlags(_ flags: FeatureFlags) async {
            await MainActor.run {
                featureFlagsSubject.send(flags)
            }
        }

        public func resetToDefaults() async {
            let defaultFlags = FeatureFlagDefaults.createDefault()
            await setFeatureFlags(defaultFlags)
        }
    }
#else
    public final class FeatureFlagsRepository: FeatureFlagsGateway, @unchecked Sendable {
        public init() { }

        public var featureFlags: AnyPublisher<FeatureFlags, Never> {
            Just(FeatureFlagDefaults.createDefault()).eraseToAnyPublisher()
        }

        public var currentFeatureFlags: FeatureFlags {
            FeatureFlagDefaults.createDefault()
        }

        public func setFeatureFlags(_: FeatureFlags) async {
            // No-op in release builds
        }

        public func resetToDefaults() async {
            // No-op in release builds
        }
    }
#endif
