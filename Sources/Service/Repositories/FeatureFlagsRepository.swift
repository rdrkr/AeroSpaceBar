// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation

/// Repository implementation for feature flags with in-memory storage.
///
/// This class provides in-memory storage for feature flags that reset to defaults on each run,
/// with reactive updates through Combine publishers. Only available in debug builds.
#if DEBUG
    @MainActor
    public final class FeatureFlagsRepository: FeatureFlagsGateway {
        private let featureFlagsSubject = CurrentValueSubject<FeatureFlags, Never>(
            FeatureFlags.defaultFlags()
        )

        /// Initializes a new FeatureFlagsRepository with default values.
        public init() { }

        // MARK: - FeatureFlagsGateway Implementation

        public var featureFlagsPublisher: AnyPublisher<FeatureFlags, Never> {
            featureFlagsSubject.eraseToAnyPublisher()
        }

        public func setFeatureFlags(_ flags: FeatureFlags) {
            featureFlagsSubject.send(flags)
        }

        public func resetToDefaults() {
            setFeatureFlags(FeatureFlags.defaultFlags())
        }
    }
#else
    @MainActor
    public final class FeatureFlagsRepository: FeatureFlagsGateway {
        public init() { }

        public var featureFlagsPublisher: AnyPublisher<FeatureFlags, Never> {
            Just(FeatureFlags.defaultFlags()).eraseToAnyPublisher()
        }

        public func setFeatureFlags(_: FeatureFlags) {
            // No-op in release builds
        }

        public func resetToDefaults() {
            // No-op in release builds
        }
    }
#endif
