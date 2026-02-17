// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Foundation

/// Mock implementation of FeatureFlagsGateway for testing.
///
/// This mock allows tests to verify feature flags interactions and control
/// the values emitted by publishers.
@MainActor
public final class MockFeatureFlagsGateway: FeatureFlagsGateway {
    // MARK: - Call Tracking

    public private(set) var setFeatureFlagsCalls: [FeatureFlags] = []
    public private(set) var resetToDefaultsCalls: Int = 0

    // MARK: - Configurable Values

    public var featureFlagsToEmit = FeatureFlags.defaultFlags() {
        didSet {
            featureFlagsSubject.send(featureFlagsToEmit)
        }
    }

    // MARK: - Subject

    private let featureFlagsSubject: CurrentValueSubject<FeatureFlags, Never>

    // MARK: - Initialization

    public init() {
        featureFlagsSubject = CurrentValueSubject(featureFlagsToEmit)
    }

    // MARK: - Publisher

    public var featureFlagsPublisher: AnyPublisher<FeatureFlags, Never> {
        featureFlagsSubject.eraseToAnyPublisher()
    }

    // MARK: - Methods

    public func setFeatureFlags(_ flags: FeatureFlags) {
        setFeatureFlagsCalls.append(flags)
        featureFlagsToEmit = flags
    }

    public func resetToDefaults() {
        resetToDefaultsCalls += 1
        let defaults = FeatureFlags.defaultFlags()
        featureFlagsToEmit = defaults
    }

    // MARK: - Test Helpers

    public func reset() {
        setFeatureFlagsCalls.removeAll()
        resetToDefaultsCalls = 0
    }

    public func emitFeatureFlags(_ flags: FeatureFlags) {
        featureFlagsSubject.send(flags)
    }
}
