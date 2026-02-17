// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Data
@testable import Domain
import Nimble
import XCTest

@MainActor
final class SystemMenuBarRepositoryTests: XCTestCase {
    private var repository: SystemMenuBarRepository?
    private var cancellables: Set<AnyCancellable> = .init()
    private var mockConfigurationGateway: MockConfigurationGateway?

    override func setUp() async throws {
        try await super.setUp()
        cancellables = Set<AnyCancellable>()
        let gateway = MockConfigurationGateway()
        mockConfigurationGateway = gateway

        repository = SystemMenuBarRepository(
            getShowGroupsUseCase: GetShowGroupsUseCase(configurationGateway: gateway),
            getHasAskedForScreenCapturePermissionsUseCase: GetHasAskedForScreenCapturePermissionsUseCase(
                configurationGateway: gateway
            ),
            setHasAskedForScreenCapturePermissionsUseCase: SetHasAskedForScreenCapturePermissionsUseCase(
                configurationGateway: gateway
            )
        )
    }

    override func tearDown() async throws {
        cancellables.removeAll()
        repository = nil
        mockConfigurationGateway = nil
        try await super.tearDown()
    }

    func testSystemMenuBarRepositoryInitialization() {
        // Given/When repository is initialized
        // Then should not be nil
        expect(self.repository).toNot(beNil())
    }

    func testWallpaperPublisher() {
        guard let repository else {
            fail("Repository not initialized")
            return
        }

        // Given repository initialized
        var receivedInitialValue = false

        // When subscribing to wallpaper publisher
        repository.wallpaperPublisher
            .sink { _ in
                receivedInitialValue = true
            }
            .store(in: &cancellables)

        // Then should receive initial value
        expect(receivedInitialValue).to(beTrue())
    }

    func testMenuBarHeightPublisher() {
        guard let repository else {
            fail("Repository not initialized")
            return
        }

        // Given repository initialized
        var receivedValue: CGFloat?

        // When subscribing to menu bar height publisher
        repository.menuBarHeightPublisher
            .sink { height in
                receivedValue = height
            }
            .store(in: &cancellables)

        // Then should receive initial value
        expect(receivedValue).toNot(beNil())
    }

    func testScreenCapturePermissionGrantedPublisher() {
        guard let repository else {
            fail("Repository not initialized")
            return
        }

        // Given repository initialized
        var receivedValue: Bool?

        // When subscribing to permission publisher
        repository.screenCapturePermissionGrantedPublisher
            .sink { granted in
                receivedValue = granted
            }
            .store(in: &cancellables)

        // Then should receive initial value
        expect(receivedValue).toNot(beNil())
    }

    func testMenuBarVisibilityPublisher() {
        guard let repository else {
            fail("Repository not initialized")
            return
        }

        // Given repository initialized
        var receivedValue: Bool?

        // When subscribing to visibility publisher
        repository.menuBarVisibilityPublisher
            .sink { visible in
                receivedValue = visible
            }
            .store(in: &cancellables)

        // Then should receive initial value
        expect(receivedValue).toNot(beNil())
    }

    func testMenuBarAppsPublisher() {
        guard let repository else {
            fail("Repository not initialized")
            return
        }

        // Given repository initialized
        var receivedValue: [MenuBarApp]?

        // When subscribing to apps publisher
        repository.menuBarAppsPublisher
            .sink { apps in
                receivedValue = apps
            }
            .store(in: &cancellables)

        // Then should receive initial value
        expect(receivedValue).toNot(beNil())
    }

    func testRequestScreenCapturePermissions() async {
        guard let repository else {
            fail("Repository not initialized")
            return
        }

        // Given repository initialized
        // When requesting permissions
        await repository.requestScreenCapturePermissions()

        // Then should complete without crashing
        // Note: Actual permission UI won't show in tests
        expect(true).to(beTrue())
    }
}
