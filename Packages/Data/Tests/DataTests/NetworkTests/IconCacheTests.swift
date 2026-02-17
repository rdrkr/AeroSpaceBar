// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
@testable import Data
import Nimble
import XCTest

@MainActor
final class IconCacheTests: XCTestCase {
    private var iconCache: IconCache?

    override func setUp() async throws {
        try await super.setUp()
        iconCache = IconCache()
    }

    override func tearDown() async throws {
        iconCache = nil
        try await super.tearDown()
    }

    func testIconCacheInitialization() {
        // Given/When icon cache is initialized
        let cache = IconCache()

        // Then it should not be nil
        expect(cache).toNot(beNil())
    }

    func testIconForRunningApplication() {
        guard let cache = iconCache else {
            fail("Icon cache not initialized")
            return
        }

        // Given Finder is a running application
        let appName = "Finder"

        // When requesting icon for running app
        let icon = cache.icon(for: appName)

        // Then should return an icon
        expect(icon).toNot(beNil())
    }

    func testIconCacheHitOnSecondRequest() {
        guard let cache = iconCache else {
            fail("Icon cache not initialized")
            return
        }

        // Given an app icon has been loaded
        let appName = "Finder"
        let firstIcon = cache.icon(for: appName)

        // When requesting the same icon again
        let secondIcon = cache.icon(for: appName)

        // Then should return the cached icon (same instance or equal)
        expect(firstIcon).toNot(beNil())
        expect(secondIcon).toNot(beNil())
        expect(secondIcon) === firstIcon // Same object reference from cache
    }

    func testIconCacheMiss() {
        guard let cache = iconCache else {
            fail("Icon cache not initialized")
            return
        }

        // Given a non-existent application name
        let appName = "NonExistentApp12345XYZ"

        // When requesting icon for non-existent app
        let icon = cache.icon(for: appName)

        // Then should return default application icon
        expect(icon).toNot(beNil())
    }

    func testIconForApplicationInApplicationsFolder() {
        guard let cache = iconCache else {
            fail("Icon cache not initialized")
            return
        }

        // Given an app that exists in Applications folder but may not be running
        // Using Safari as it's commonly installed
        let appName = "Safari"

        // When requesting icon
        let icon = cache.icon(for: appName)

        // Then should return an icon
        expect(icon).toNot(beNil())
    }

    func testIconForSystemApplication() {
        guard let cache = iconCache else {
            fail("Icon cache not initialized")
            return
        }

        // Given a system application
        let appName = "Calculator"

        // When requesting icon
        let icon = cache.icon(for: appName)

        // Then should return an icon
        expect(icon).toNot(beNil())
    }

    func testCaseSensitiveAppName() {
        guard let cache = iconCache else {
            fail("Icon cache not initialized")
            return
        }

        // Given an app name with different casing
        let lowerCase = "finder"
        let properCase = "Finder"

        // When requesting icons with different casings
        let icon1 = cache.icon(for: lowerCase)
        let icon2 = cache.icon(for: properCase)

        // Then should return icons for both (case-insensitive matching)
        expect(icon1).toNot(beNil())
        expect(icon2).toNot(beNil())
    }

    func testMultipleDifferentAppsAreCached() {
        guard let cache = iconCache else {
            fail("Icon cache not initialized")
            return
        }

        // Given multiple different applications
        let apps = ["Finder", "Safari", "Calculator"]

        // When loading icons for all apps
        let icons = apps.map { cache.icon(for: $0) }

        // Then all should return icons
        icons.forEach { icon in
            expect(icon).toNot(beNil())
        }
    }

    func testDefaultIconReturnedForUnknownApp() {
        guard let cache = iconCache else {
            fail("Icon cache not initialized")
            return
        }

        // Given a completely unknown app name
        let unknownApp = "ThisAppDefinitelyDoesNotExist123456789"

        // When requesting icon
        let icon = cache.icon(for: unknownApp)

        // Then should return a default icon (not nil)
        expect(icon).toNot(beNil())

        // And requesting again should return cached version
        let cachedIcon = cache.icon(for: unknownApp)
        expect(cachedIcon) === icon
    }
}
