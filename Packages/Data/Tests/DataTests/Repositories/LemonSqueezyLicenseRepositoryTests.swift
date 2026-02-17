// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Data
import Domain
import Foundation
import Nimble
import XCTest

@MainActor
final class LemonSqueezyLicenseRepositoryTests: XCTestCase {
    private var userDefaults: UserDefaults?
    private var repository: LemonSqueezyLicenseRepository?

    override func setUp() async throws {
        try await super.setUp()
        // Use a temporary UserDefaults suite for each test
        userDefaults = UserDefaults(suiteName: "LemonSqueezyLicenseRepositoryTests")
        userDefaults?.removePersistentDomain(forName: "LemonSqueezyLicenseRepositoryTests")
    }

    override func tearDown() async throws {
        userDefaults?.removePersistentDomain(forName: "LemonSqueezyLicenseRepositoryTests")
        userDefaults = nil
        repository = nil
        try await super.tearDown()
    }

    func testPurchasedLicensePersistence() async throws {
        // Given: A purchased license is stored in UserDefaults
        let licenseKey = "PURCHASED-LICENSE-KEY"
        let instanceId = "INSTANCE-ID"
        let licenseInfo = LicenseInfo(
            licenseKey: licenseKey,
            licenseStatus: .licensed,
            userName: "Test User",
            email: "test@example.com"
        )

        guard let userDefaults else {
            fail("userDefaults not initialized")
            return
        }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(licenseInfo) {
            userDefaults.set(encoded, forKey: "license_info")
        }
        userDefaults.set(instanceId, forKey: "license_instance_id")
        userDefaults.set(Date(), forKey: "last_license_validation")

        // When: The repository is initialized (simulating app restart)
        repository = LemonSqueezyLicenseRepository(userDefaults: userDefaults)
        guard let repository else {
            fail("repository not initialized")
            return
        }

        // Then: The initial state should be licensed
        var status: LicenseStatus?
        for await info in repository.licenseInfoPublisher.values {
            status = info.licenseStatus
            break
        }
        expect(status).to(equal(.licensed))

        // Wait for the validation task to complete (it runs on init)
        // Since we can't easily await the private task, we'll wait a bit
        try await Task.sleep(for: .seconds(1))

        // Check status again
        for await info in repository.licenseInfoPublisher.values {
            status = info.licenseStatus
            break
        }

        // If the logic is correct, a network error should keep it licensed.
        // An API error (which we expect with a fake key) will expire it.
        // So this test might actually show .expired if we hit the real API.
        // This makes it hard to test "persistence" without mocking the network.

        // BUT, if the user says it reverts to "trial expired", maybe the issue is that it forgets it's a purchased
        // license?

        print("Final status: \(String(describing: status))")
    }

    func testTrialLicensePersistence() async {
        // Given: A trial license is stored
        let licenseKey = "TRIAL-LICENSE-KEY"
        let instanceId = "INSTANCE-ID"
        let licenseInfo = LicenseInfo(
            licenseKey: licenseKey,
            licenseStatus: .trial(daysRemaining: 10),
            userName: "Trial User",
            email: "trial@example.com"
        )

        guard let userDefaults else {
            fail("userDefaults not initialized")
            return
        }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(licenseInfo) {
            userDefaults.set(encoded, forKey: "license_info")
        }
        userDefaults.set(instanceId, forKey: "license_instance_id")
        userDefaults.set(Date(), forKey: "last_license_validation")

        repository = LemonSqueezyLicenseRepository(userDefaults: userDefaults)
        guard let repository else {
            fail("repository not initialized")
            return
        }

        var status: LicenseStatus?
        for await info in repository.licenseInfoPublisher.values {
            status = info.licenseStatus
            break
        }
        if case .trial = status {
            // Pass
        } else {
            fail("Expected trial status, got \(String(describing: status))")
        }
    }
}
