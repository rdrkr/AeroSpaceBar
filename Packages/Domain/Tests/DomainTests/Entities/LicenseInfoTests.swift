// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

final class LicenseInfoTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitWithDefaultValues() {
        // When creating license info with no parameters
        let info = LicenseInfo()

        // Then it should have correct default values
        expect(info.licenseKey.isEmpty) == true
        expect(info.licenseStatus) == .unknown
        expect(info.userName.isEmpty) == true
        expect(info.email.isEmpty) == true
        expect(info.profileImageData).to(beNil())
        expect(info.isActive) == false
    }

    func testInitWithAllParameters() {
        // Given all parameters
        let profileData = Data("MOCK_IMAGE".utf8)

        // When creating license info with all parameters
        let info = LicenseInfo(
            licenseKey: "ABC-123-XYZ",
            licenseStatus: .licensed,
            userName: "John Doe",
            email: "john@example.com",
            profileImageData: profileData
        )

        // Then all properties should be set correctly
        expect(info.licenseKey) == "ABC-123-XYZ"
        expect(info.licenseStatus) == .licensed
        expect(info.userName) == "John Doe"
        expect(info.email) == "john@example.com"
        expect(info.profileImageData) == profileData
        expect(info.isActive) == true
    }

    // MARK: - isActive Computed Property Tests

    func testIsActiveWithLicensedStatus() {
        // Given licensed status
        let info = LicenseInfo(licenseStatus: .licensed)

        // Then should be active
        expect(info.isActive) == true
    }

    func testIsActiveWithTrialStatus() {
        // Given trial status with days remaining
        let info = LicenseInfo(licenseStatus: .trial(daysRemaining: 10))

        // Then should be active
        expect(info.isActive) == true
    }

    func testIsActiveWithTrialStatusOneDayRemaining() {
        // Given trial status with 1 day remaining
        let info = LicenseInfo(licenseStatus: .trial(daysRemaining: 1))

        // Then should still be active
        expect(info.isActive) == true
    }

    func testIsNotActiveWithExpiredStatus() {
        // Given expired status
        let info = LicenseInfo(licenseStatus: .expired)

        // Then should not be active
        expect(info.isActive) == false
    }

    func testIsNotActiveWithValidatingStatus() {
        // Given validating status
        let info = LicenseInfo(licenseStatus: .validating)

        // Then should not be active
        expect(info.isActive) == false
    }

    func testIsNotActiveWithUnknownStatus() {
        // Given unknown status
        let info = LicenseInfo(licenseStatus: .unknown)

        // Then should not be active
        expect(info.isActive) == false
    }

    // MARK: - Coding Tests

    func testEncoding() throws {
        // Given license info with all properties
        let profileData = Data("MOCK_IMAGE".utf8)
        let info = LicenseInfo(
            licenseKey: "TEST-KEY-123",
            licenseStatus: .licensed,
            userName: "Test User",
            email: "test@example.com",
            profileImageData: profileData
        )

        // When encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(info)

        // Then it should encode without errors
        expect(data).toNot(beEmpty())

        // And should be decodable
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(LicenseInfo.self, from: data)
        expect(decoded.licenseKey) == "TEST-KEY-123"
        expect(decoded.userName) == "Test User"
        expect(decoded.email) == "test@example.com"
    }

    func testDecodingWithAllFields() throws {
        // Given JSON with all fields
        let json = """
        {
            "licenseKey": "DECODE-TEST-KEY",
            "licenseStatus": {
                "licensed": {}
            },
            "userName": "Decoder User",
            "email": "decoder@test.com"
        }
        """

        // When decoding
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let info = try decoder.decode(LicenseInfo.self, from: data)

        // Then it should decode correctly
        expect(info.licenseKey) == "DECODE-TEST-KEY"
        expect(info.licenseStatus) == .licensed
        expect(info.userName) == "Decoder User"
        expect(info.email) == "decoder@test.com"
    }

    func testRoundTripCoding() throws {
        // Given license info
        let original = LicenseInfo(
            licenseKey: "ROUNDTRIP-KEY",
            licenseStatus: .trial(daysRemaining: 5),
            userName: "Round Trip",
            email: "roundtrip@test.com",
            profileImageData: Data("DATA".utf8)
        )

        // When encoding and decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(LicenseInfo.self, from: data)

        // Then should match original
        expect(decoded.licenseKey) == original.licenseKey
        expect(decoded.licenseStatus) == original.licenseStatus
        expect(decoded.userName) == original.userName
        expect(decoded.email) == original.email
        expect(decoded.profileImageData) == original.profileImageData
    }

    // MARK: - Equality Tests

    func testEqualityWithSameValues() {
        // Given two license infos with identical values
        let info1 = LicenseInfo(
            licenseKey: "KEY",
            licenseStatus: .licensed,
            userName: "User",
            email: "user@test.com"
        )
        let info2 = LicenseInfo(
            licenseKey: "KEY",
            licenseStatus: .licensed,
            userName: "User",
            email: "user@test.com"
        )

        // Then they should be equal
        expect(info1) == info2
    }

    func testEqualityWithDifferentKeys() {
        // Given two license infos with different keys
        let info1 = LicenseInfo(licenseKey: "KEY1")
        let info2 = LicenseInfo(licenseKey: "KEY2")

        // Then they should not be equal
        expect(info1) != info2
    }

    func testEqualityWithDifferentStatus() {
        // Given two license infos with different statuses
        let info1 = LicenseInfo(licenseKey: "KEY", licenseStatus: .licensed)
        let info2 = LicenseInfo(licenseKey: "KEY", licenseStatus: .expired)

        // Then they should not be equal
        expect(info1) != info2
    }

    func testEqualityWithDifferentUserNames() {
        // Given two license infos with different user names
        let info1 = LicenseInfo(licenseKey: "KEY", userName: "User1")
        let info2 = LicenseInfo(licenseKey: "KEY", userName: "User2")

        // Then they should not be equal
        expect(info1) != info2
    }

    // MARK: - Fixture Tests

    func testUnknownFixture() {
        // Given unknown fixture
        let info = LicenseFixtures.unknown

        // Then should have correct values
        expect(info.licenseKey.isEmpty) == true
        expect(info.licenseStatus) == .unknown
        expect(info.isActive) == false
    }

    func testLicensedFixture() {
        // Given licensed fixture
        let info = LicenseFixtures.licensed

        // Then should have correct values
        expect(info.licenseKey) == LicenseFixtures.validPurchasedKey
        expect(info.licenseStatus) == .licensed
        expect(info.isActive) == true
        expect(info.userName) == "John Doe"
        expect(info.email) == "john.doe@example.com"
    }

    func testTrialFixtures() {
        // Given trial fixtures
        let trial10 = LicenseFixtures.trial10Days
        let trial3 = LicenseFixtures.trial3Days
        let trial1 = LicenseFixtures.trial1Day

        // Then should have correct values
        expect(trial10.licenseStatus) == .trial(daysRemaining: 10)
        expect(trial10.isActive) == true

        expect(trial3.licenseStatus) == .trial(daysRemaining: 3)
        expect(trial3.isActive) == true

        expect(trial1.licenseStatus) == .trial(daysRemaining: 1)
        expect(trial1.isActive) == true
    }

    func testExpiredTrialFixture() {
        // Given expired trial fixture
        let info = LicenseFixtures.expiredTrial

        // Then should have correct values
        expect(info.licenseStatus) == .expired
        expect(info.isActive) == false
    }

    func testFixtureBuilders() {
        // Test fixture builder methods
        let customLicensed = LicenseFixtures.licensed(
            key: "CUSTOM-KEY",
            userName: "Custom User",
            email: "custom@test.com"
        )
        expect(customLicensed.licenseKey) == "CUSTOM-KEY"
        expect(customLicensed.userName) == "Custom User"
        expect(customLicensed.email) == "custom@test.com"
        expect(customLicensed.isActive) == true

        let customTrial = LicenseFixtures.trial(daysRemaining: 7)
        expect(customTrial.licenseStatus) == .trial(daysRemaining: 7)
        expect(customTrial.isActive) == true

        let customExpired = LicenseFixtures.expired(key: "EXPIRED-KEY")
        expect(customExpired.licenseKey) == "EXPIRED-KEY"
        expect(customExpired.isActive) == false
    }

    // MARK: - Critical Bug Fix Tests

    func testPurchasedLicenseShouldNotBeExpired() {
        // Given a purchased license (not trial)
        // This tests the fix for the bug where purchased licenses were incorrectly expired
        let info = LicenseFixtures.licensed

        // Then should be active (not expired)
        expect(info.licenseStatus) == .licensed
        expect(info.isActive) == true
    }

    func testExpiredStatusMeansInactive() {
        // Given an expired status (could be trial OR purchased)
        let expired = LicenseInfo(licenseStatus: .expired)

        // Then should not be active
        expect(expired.isActive) == false
    }

    func testTrialWithZeroDaysIsStillTrial() {
        // Given a trial with 0 days (edge case)
        let info = LicenseInfo(licenseStatus: .trial(daysRemaining: 0))

        // Then should still be considered a trial (though expired)
        expect(info.isActive) == true // 0 days is still technically "active" trial
    }

    // MARK: - Edge Cases

    func testEmptyLicenseKey() {
        // Given empty license key
        let info = LicenseInfo(licenseKey: "")

        // Then should be valid (unknown status)
        expect(info.licenseKey.isEmpty) == true
        expect(info.isActive) == false
    }

    func testVeryLongLicenseKey() {
        // Given a very long license key
        let longKey = String(repeating: "ABCD-", count: 100)
        let info = LicenseInfo(licenseKey: longKey, licenseStatus: .licensed)

        // Then should handle it correctly
        expect(info.licenseKey.count) == 500
        expect(info.isActive) == true
    }

    func testSpecialCharactersInUserData() {
        // Given special characters in user data
        let info = LicenseInfo(
            licenseKey: "KEY",
            licenseStatus: .licensed,
            userName: "User 🚀 Name",
            email: "user+tag@example.com"
        )

        // Then should preserve special characters
        expect(info.userName) == "User 🚀 Name"
        expect(info.email) == "user+tag@example.com"
    }

    func testLargeProfileImageData() {
        // Given large profile image data
        let largeData = Data(repeating: 0xFF, count: 1_000_000) // 1MB

        let info = LicenseInfo(
            licenseKey: "KEY",
            licenseStatus: .licensed,
            profileImageData: largeData
        )

        // Then should handle large data
        expect(info.profileImageData?.count) == 1_000_000
    }
}
