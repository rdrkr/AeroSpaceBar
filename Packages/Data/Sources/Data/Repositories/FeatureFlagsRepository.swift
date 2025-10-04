// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation

/// Repository implementation for feature flags with in-memory storage.
///
/// This class provides in-memory storage for feature flags that reset to defaults on each run,
/// with reactive updates through Combine publishers. Feature flags are automatically disabled
/// when no active license is present (if licensing is enabled). Only available in debug builds.
@MainActor
public final class FeatureFlagsRepository: FeatureFlagsGateway {
    @Published private var licenseInfo: LicenseInfo

    private let baseFeatureFlagsSubject = CurrentValueSubject<FeatureFlags, Never>(
        FeatureFlags.defaultFlags()
    )

    private let computedFeatureFlagsSubject = CurrentValueSubject<FeatureFlags, Never>(
        FeatureFlags.defaultFlags()
    )

    /// Use case for retrieving license information.
    private let getLicenseInfoUseCase: GetLicenseInfoUseCase

    /// Use case for retrieving enableLicensing feature flag.
    private let getEnableLicensingUseCase: GetEnableLicensingUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables = Set<AnyCancellable>()

    /// Initializes a new FeatureFlagsRepository with required use cases.
    /// - Parameters:
    ///   - getLicenseInfoUseCase: Use case for retrieving license information
    ///   - getEnableLicensingUseCase: Use case for retrieving enableLicensing flag
    public init(
        getLicenseInfoUseCase: GetLicenseInfoUseCase,
        getEnableLicensingUseCase: GetEnableLicensingUseCase
    ) {
        self.getLicenseInfoUseCase = getLicenseInfoUseCase
        self.getEnableLicensingUseCase = getEnableLicensingUseCase

        licenseInfo = getLicenseInfoUseCase.execute().blockingFirst()

        setupLicenseAwareFeatureFlags()
    }

    // MARK: - FeatureFlagsGateway Implementation

    public var featureFlagsPublisher: AnyPublisher<FeatureFlags, Never> {
        computedFeatureFlagsSubject.eraseToAnyPublisher()
    }

    public func setFeatureFlags(_ flags: FeatureFlags) {
        let baseFlags = baseFeatureFlagsSubject.value
        guard flags != baseFlags else { return }

        let newFlags = if licenseInfo.isActive {
            flags
        } else {
            baseFlags.copyWithUpdatedNonRequiredLicenseFlags(other: flags)
        }

        if newFlags != baseFlags {
            baseFeatureFlagsSubject.send(newFlags)
        }
    }

    public func resetToDefaults() {
        setFeatureFlags(FeatureFlags.defaultFlags())
    }

    // MARK: - Private Methods

    /// Sets up reactive subscriptions to compute feature flags based on license state.
    ///
    /// This method combines base feature flags with license information to ensure
    /// feature flags are disabled when no active license is present (if licensing is enabled).
    private func setupLicenseAwareFeatureFlags() {
        // Subscribe to license info changes
        getLicenseInfoUseCase.execute()
            .assign(to: \.licenseInfo, on: self)
            .store(in: &cancellables)

        Publishers.CombineLatest3(
            baseFeatureFlagsSubject,
            getLicenseInfoUseCase.execute(),
            getEnableLicensingUseCase.execute()
        )
        .map { baseFlags, licenseInfo, enableLicensing in
            // If licensing is disabled, return base flags as-is
            guard enableLicensing else {
                return baseFlags
            }

            // If licensing is enabled but no active license, disable all flags
            guard licenseInfo.isActive else {
                return baseFlags.copyWithDisabledRequiredLicenseFlags()
            }

            // If licensed, return base flags
            return baseFlags
        }
        .assign(to: \.value, on: computedFeatureFlagsSubject)
        .store(in: &cancellables)
    }
}
