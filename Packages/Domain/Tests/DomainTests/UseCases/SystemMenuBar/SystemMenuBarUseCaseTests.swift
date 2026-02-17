// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for SystemMenuBar UseCases.
///
/// These tests verify:
/// - GetWallpaperUseCase
/// - GetMenuBarHeightUseCase
/// - GetMenuBarVisibilityUseCase
/// - GetMenuBarAppsUseCase
/// - GetScreenCapturePermissionGrantedUseCase
/// - RequestScreenCapturePermissionsUseCase
@MainActor
final class SystemMenuBarUseCaseTests: XCTestCase {
    private var mockGateway: MockSystemMenuBarGateway?
    private var cancellables: Set<AnyCancellable>?
    private var receivedPermission: Bool?
    private var receivedHeight: Double?
    private var receivedVisibility: Bool?
    private var receivedApps: [MenuBarApp]?
    private var receivedValue: NSImage?
    private var receivedImage: NSImage?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockSystemMenuBarGateway()
        cancellables = []
    }

    override func tearDown() async throws {
        cancellables?.removeAll()
        mockGateway = nil
        receivedPermission = nil
        receivedHeight = nil
        receivedVisibility = nil
        receivedApps = nil
        try await super.tearDown()
    }

    // MARK: - GetWallpaperUseCase Tests

    func testGetWallpaperWithNilValue() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.wallpaper = nil
        let useCase = GetWallpaperUseCase(systemMenuBarGateway: mockGateway)
        var receivedValue: NSImage?
        var wasCalled = false

        // When
        useCase.execute()
            .sink { value in
                receivedValue = value
                wasCalled = true
            }
            .store(in: &cancellables)

        // Then
        expect(wasCalled) == true
        expect(receivedValue).to(beNil())
    }

    func testGetWallpaperWithImage() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let testImage = NSImage(size: NSSize(width: 100, height: 100))
        mockGateway.wallpaper = testImage
        let useCase = GetWallpaperUseCase(systemMenuBarGateway: mockGateway)

        // When
        useCase.execute()
            .sink { value in self.receivedImage = value }
            .store(in: &cancellables)

        // Then
        expect(self.receivedImage) == testImage
    }

    // MARK: - GetMenuBarHeightUseCase Tests

    func testGetMenuBarHeight() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.menuBarHeight = 22.0
        let useCase = GetMenuBarHeightUseCase(systemMenuBarGateway: mockGateway)

        // When
        useCase.execute()
            .sink { value in self.receivedHeight = value }
            .store(in: &cancellables)

        // Then
        expect(self.receivedHeight).toNot(beNil())
        expect(self.receivedHeight) == 22.0
    }

    func testGetMenuBarHeightWithCustomValue() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let customHeight = 30.5
        mockGateway.menuBarHeight = customHeight
        let useCase = GetMenuBarHeightUseCase(systemMenuBarGateway: mockGateway)

        // When
        useCase.execute()
            .sink { value in self.receivedHeight = value }
            .store(in: &cancellables)

        // Then
        expect(self.receivedHeight) == customHeight
    }

    // MARK: - GetMenuBarVisibilityUseCase Tests

    func testGetMenuBarVisibilityWhenVisible() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.menuBarVisibility = true
        let useCase = GetMenuBarVisibilityUseCase(systemMenuBarGateway: mockGateway)

        // When
        useCase.execute()
            .sink { value in self.receivedVisibility = value }
            .store(in: &cancellables)

        // Then
        expect(self.receivedVisibility).toNot(beNil())
        expect(self.receivedVisibility ?? false) == true
    }

    func testGetMenuBarVisibilityWhenHidden() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.menuBarVisibility = false
        let useCase = GetMenuBarVisibilityUseCase(systemMenuBarGateway: mockGateway)

        // When
        useCase.execute()
            .sink { value in self.receivedVisibility = value }
            .store(in: &cancellables)

        // Then
        expect(self.receivedVisibility).toNot(beNil())
        expect(self.receivedVisibility ?? true) == false
    }

    // MARK: - GetMenuBarAppsUseCase Tests

    func testGetMenuBarAppsWithEmptyList() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.menuBarApps = []
        let useCase = GetMenuBarAppsUseCase(systemMenuBarGateway: mockGateway)

        // When
        useCase.execute()
            .sink { value in self.receivedApps = value }
            .store(in: &cancellables)

        // Then
        expect(self.receivedApps).toNot(beNil())
        expect(self.receivedApps?.isEmpty) == true
    }

    func testGetMenuBarAppsWithMultipleApps() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let app1 = MenuBarApp(id: "app1", frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let app2 = MenuBarApp(id: "app2", frame: CGRect(x: 25, y: 0, width: 20, height: 20))
        let app3 = MenuBarApp(id: "app3", frame: CGRect(x: 50, y: 0, width: 20, height: 20))
        mockGateway.menuBarApps = [app1, app2, app3]
        let useCase = GetMenuBarAppsUseCase(systemMenuBarGateway: mockGateway)

        // When
        useCase.execute()
            .sink { value in self.receivedApps = value }
            .store(in: &cancellables)

        // Then
        expect(self.receivedApps).toNot(beNil())
        expect(self.receivedApps?.count) == 3
        expect(self.receivedApps?[0].id) == "app1"
        expect(self.receivedApps?[1].id) == "app2"
        expect(self.receivedApps?[2].id) == "app3"
    }

    // MARK: - GetScreenCapturePermissionGrantedUseCase Tests

    func testGetScreenCapturePermissionGrantedWhenDenied() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.screenCapturePermissionGranted = false
        let useCase = GetScreenCapturePermissionGrantedUseCase(systemMenuBarGateway: mockGateway)

        // When
        useCase.execute()
            .sink { value in self.receivedPermission = value }
            .store(in: &cancellables)

        // Then
        expect(self.receivedPermission).toNot(beNil())
        expect(self.receivedPermission ?? true) == false
    }

    func testGetScreenCapturePermissionGrantedWhenGranted() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.screenCapturePermissionGranted = true
        let useCase = GetScreenCapturePermissionGrantedUseCase(systemMenuBarGateway: mockGateway)

        // When
        useCase.execute()
            .sink { value in self.receivedPermission = value }
            .store(in: &cancellables)

        // Then
        expect(self.receivedPermission).toNot(beNil())
        expect(self.receivedPermission ?? false) == true
    }

    // MARK: - RequestScreenCapturePermissionsUseCase Tests

    func testRequestScreenCapturePermissions() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.screenCapturePermissionGranted = false
        let useCase = RequestScreenCapturePermissionsUseCase(systemMenuBarGateway: mockGateway)

        // When
        await useCase.execute()

        // Then
        expect(mockGateway.screenCapturePermissionGranted) == true
    }

    // MARK: - Integration Tests

    func testMultiplePublisherSubscriptions() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.menuBarHeight = 24.0
        mockGateway.menuBarVisibility = true
        mockGateway.menuBarApps = [
            MenuBarApp(id: "app1", frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        ]

        let heightUseCase = GetMenuBarHeightUseCase(systemMenuBarGateway: mockGateway)
        let visibilityUseCase = GetMenuBarVisibilityUseCase(systemMenuBarGateway: mockGateway)
        let appsUseCase = GetMenuBarAppsUseCase(systemMenuBarGateway: mockGateway)

        // When
        heightUseCase.execute()
            .sink { value in self.receivedHeight = value }
            .store(in: &cancellables)

        visibilityUseCase.execute()
            .sink { value in self.receivedVisibility = value }
            .store(in: &cancellables)

        appsUseCase.execute()
            .sink { value in self.receivedApps = value }
            .store(in: &cancellables)

        // Then
        expect(self.receivedHeight) == 24.0
        expect(self.receivedVisibility ?? false) == true
        expect(self.receivedApps?.count) == 1
    }
}
