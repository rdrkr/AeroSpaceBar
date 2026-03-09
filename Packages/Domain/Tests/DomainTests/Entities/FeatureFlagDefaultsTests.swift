// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for FeatureFlagDefaults enum.
///
/// These tests verify FeatureFlagDefaults static properties and build configuration
/// differences between debug and release builds.
@MainActor
final class FeatureFlagDefaultsTests: XCTestCase {
    // MARK: - Core Feature Default Tests

    func testEnableSpacesDefault() {
        // Given default value for spaces
        let defaultValue = FeatureFlagDefaults.enableSpaces

        // Then should be enabled (stable feature)
        expect(defaultValue) == true
    }

    func testEnableAdvancedSettingsDefault() {
        // Given default value for advanced settings
        let defaultValue = FeatureFlagDefaults.enableAdvancedSettings

        // Then should be enabled
        expect(defaultValue) == true
    }

    func testEnableGroupsDefault() {
        // Given default value for groups
        let defaultValue = FeatureFlagDefaults.enableGroups

        // Then should be enabled (stable feature)
        expect(defaultValue) == true
    }

    func testEnableSoftwareUpdatesDefault() {
        // Given default value for software updates
        let defaultValue = FeatureFlagDefaults.enableSoftwareUpdates

        // Then should be enabled
        expect(defaultValue) == true
    }

    func testEnableLicensingDefault() {
        // Given default value for licensing
        let defaultValue = FeatureFlagDefaults.enableLicensing

        // Then should be disabled (open source - all features free)
        expect(defaultValue) == false
    }

    // MARK: - Build Configuration Tests

    #if DEBUG
        func testEnableTrialRequestDebugDefault() {
            // Given default value for trial request in DEBUG
            let defaultValue = FeatureFlagDefaults.enableTrialRequest

            // Then should be enabled in debug builds
            expect(defaultValue) == true
        }

        func testMockActiveLicenseDebugDefault() {
            // Given default value for mock active license in DEBUG
            let defaultValue = FeatureFlagDefaults.mockActiveLicense

            // Then should be disabled by default
            expect(defaultValue) == false
        }

        func testCheckoutEnvironmentDebugDefault() {
            // Given default checkout environment in DEBUG
            let defaultValue = FeatureFlagDefaults.checkoutEnvironment

            // Then should be development environment
            expect(defaultValue).to(
                equal(.development),
                description: "Checkout environment should be development in DEBUG builds"
            )
        }

        func testDebugOnlyPropertiesExist() {
            // Given DEBUG build
            // Then debug-only properties should exist
            let mockLicense: Bool = FeatureFlagDefaults.mockActiveLicense
            let checkoutEnv: CheckoutEnvironment = FeatureFlagDefaults.checkoutEnvironment

            expect(mockLicense).toNot(beNil())
            expect(checkoutEnv).toNot(beNil())
        }
    #else
        func testEnableTrialRequestReleaseDefault() {
            // Given default value for trial request in RELEASE
            let defaultValue = FeatureFlagDefaults.enableTrialRequest

            // Then should be disabled in release builds
            expect(defaultValue) == false
        }
    #endif

    // MARK: - Consistency Tests

    func testAllCoreFeatureDefaults() {
        // Given all core feature defaults (excluding licensing which is intentionally disabled)
        let coreDefaults = [
            FeatureFlagDefaults.enableSpaces,
            FeatureFlagDefaults.enableAdvancedSettings,
            FeatureFlagDefaults.enableGroups,
            FeatureFlagDefaults.enableSoftwareUpdates
        ]

        // Then all core features should be enabled by default
        for defaultValue in coreDefaults {
            expect(defaultValue) == true
        }

        // Licensing is intentionally disabled (open source)
        expect(FeatureFlagDefaults.enableLicensing) == false
    }

    func testDefaultsAreStaticProperties() {
        // Given defaults are static
        // When accessing multiple times
        let value1 = FeatureFlagDefaults.enableSpaces
        let value2 = FeatureFlagDefaults.enableSpaces

        // Then should return consistent values
        expect(value1) == value2
    }

    // MARK: - Integration Tests

    func testDefaultsMatchFeatureFlagsDefaults() {
        // Given default flags created from defaults
        let flags = FeatureFlags.defaultFlags()

        // Then should match individual defaults
        expect(flags.enableSpaces) == FeatureFlagDefaults.enableSpaces
        expect(flags.enableAdvancedSettings) == FeatureFlagDefaults.enableAdvancedSettings
        expect(flags.enableGroups) == FeatureFlagDefaults.enableGroups
        expect(flags.enableSoftwareUpdates) == FeatureFlagDefaults.enableSoftwareUpdates
    }

    // MARK: - Type Tests

    func testEnableSpacesIsBool() {
        // Given enableSpaces
        _ = FeatureFlagDefaults.enableSpaces

        // Then should be Bool type
    }

    func testEnableLicensingIsBool() {
        // Given enableLicensing
        _ = FeatureFlagDefaults.enableLicensing

        // Then should be Bool type
    }

    #if DEBUG
        func testCheckoutEnvironmentIsCheckoutEnvironment() {
            // Given checkoutEnvironment
            _ = FeatureFlagDefaults.checkoutEnvironment

            // Then should be CheckoutEnvironment type
        }
    #endif

    // MARK: - Documentation Tests

    func testStableFeaturesAreEnabled() {
        // Given documented stable features (spaces, groups)
        let stableFeatures = [
            FeatureFlagDefaults.enableSpaces,
            FeatureFlagDefaults.enableGroups
        ]

        // Then all stable features should be enabled
        for stableFeature in stableFeatures {
            expect(stableFeature) == true
        }
    }
}
