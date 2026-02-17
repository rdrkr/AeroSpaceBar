// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
@testable import Domain
import Nimble
import XCTest

@MainActor
final class SystemMenuBarGatewayTests: XCTestCase {
    private var mockGateway: MockSystemMenuBarGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockSystemMenuBarGateway()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() async throws {
        cancellables?.removeAll()
        mockGateway = nil
        try await super.tearDown()
    }

    func testWallpaperPublisher() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "Wallpaper received")
        var receivedImage: NSImage?

        // When subscribing to publisher
        mockGateway.wallpaperPublisher
            .dropFirst()
            .sink { image in
                receivedImage = image
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // And sending test image
        let testImage = NSImage(size: NSSize(width: 100, height: 100))
        mockGateway.emitWallpaper(testImage)

        // Then should receive image
        wait(for: [expectation], timeout: 1.0)
        expect(receivedImage).toNot(beNil())
        expect(receivedImage?.size) == NSSize(width: 100, height: 100)
    }

    func testWallpaperPublisherWithNilImage() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "Nil wallpaper received")
        expectation.expectedFulfillmentCount = 2 // Initial + nil
        var receivedValues: [NSImage?] = []
        mockGateway.wallpaper = NSImage() // Set initial non-nil value

        // When subscribing to publisher
        mockGateway.wallpaperPublisher
            .sink { image in
                receivedValues.append(image)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // And emitting nil wallpaper
        mockGateway.emitWallpaper(nil)

        // Then should receive values
        wait(for: [expectation], timeout: 1.0)
        expect(receivedValues.count) == 2
        expect(receivedValues[0]).toNot(beNil())
        expect(receivedValues[1]).to(beNil())
    }

    func testMenuBarVisibilityPublisher() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "Menu bar visibility received")
        expectation.expectedFulfillmentCount = 2
        var receivedValues: [Bool] = []

        // When subscribing to publisher
        mockGateway.menuBarVisibilityPublisher
            .dropFirst()
            .sink { isVisible in
                receivedValues.append(isVisible)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // And sending visibility updates
        mockGateway.emitMenuBarVisibility(true)
        mockGateway.emitMenuBarVisibility(false)

        // Then should receive both values
        wait(for: [expectation], timeout: 1.0)
        expect(receivedValues.count) == 2
        expect(receivedValues[0]) == true
        expect(receivedValues[1]) == false
    }

    func testMenuBarHeightPublisher() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "Menu bar height received")
        var receivedHeight: Double?

        // When subscribing to publisher
        mockGateway.menuBarHeightPublisher
            .dropFirst()
            .sink { height in
                receivedHeight = height
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // And updating height
        mockGateway.emitMenuBarHeight(45.0)

        // Then should receive height
        wait(for: [expectation], timeout: 1.0)
        expect(receivedHeight) == 45.0
    }

    func testMenuBarAppsPublisher() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "Menu bar apps received")
        var receivedApps: [MenuBarApp]?

        // When subscribing to publisher
        mockGateway.menuBarAppsPublisher
            .dropFirst()
            .sink { apps in
                receivedApps = apps
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // And sending test menu bar apps
        let app1 = MenuBarApp(id: "com.apple.wifi", frame: CGRect(x: 10, y: 0, width: 20, height: 39))
        let app2 = MenuBarApp(id: "com.apple.battery", frame: CGRect(x: 40, y: 0, width: 30, height: 39))
        mockGateway.emitMenuBarApps([app1, app2])

        // Then should receive apps
        wait(for: [expectation], timeout: 1.0)
        expect(receivedApps).toNot(beNil())
        expect(receivedApps?.count) == 2
        expect(receivedApps?.first?.id) == "com.apple.wifi"
        expect(receivedApps?.last?.id) == "com.apple.battery"
    }

    func testScreenCapturePermissionGrantedPublisher() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "Screen capture permission status received")
        var receivedStatus: Bool?

        // When subscribing to publisher
        mockGateway.screenCapturePermissionGrantedPublisher
            .dropFirst()
            .sink { granted in
                receivedStatus = granted
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // And updating permission status
        mockGateway.emitScreenCapturePermissionGranted(true)

        // Then should receive status
        wait(for: [expectation], timeout: 1.0)
        expect(receivedStatus) == true
    }

    func testRequestScreenCapturePermissions() {
        guard let mockGateway else {
            fail("Mock gateway not initialized")
            return
        }

        // Given initial state
        expect(mockGateway.requestScreenCapturePermissionsCalls) == 0

        // When requesting permissions
        mockGateway.requestScreenCapturePermissions()

        // Then should mark as called
        expect(mockGateway.requestScreenCapturePermissionsCalls) == 1
    }
}
