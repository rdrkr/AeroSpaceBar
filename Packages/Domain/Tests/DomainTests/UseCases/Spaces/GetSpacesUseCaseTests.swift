// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import SwiftUI
import XCTest

/// Tests for GetSpacesUseCase.
///
/// These tests verify that the use case correctly retrieves spaces from the gateway
/// and properly publishes them to subscribers.
@MainActor
final class GetSpacesUseCaseTests: XCTestCase {
    private var sut: GetSpacesUseCase?
    private var mockGateway: MockSpacesGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        let gateway = MockSpacesGateway()
        mockGateway = gateway
        sut = GetSpacesUseCase(spacesGateway: gateway)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        cancellables?.removeAll()
    }

    // MARK: - Basic Functionality Tests

    func testExecuteReturnsPublisher() {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // When executing the use case
        let publisher = sut.execute()

        // Then it should return a non-nil publisher
        expect(publisher).toNot(beNil())
    }

    func testExecuteReturnsSpacesFromGateway() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given spaces in the gateway
        let expectedSpaces = [
            SpaceFixtures.basic,
            SpaceFixtures.focused,
            SpaceFixtures.withWindows
        ]
        mockGateway.emitSpaces(expectedSpaces)

        // When executing the use case
        let publisher = sut.execute()

        // Then it should emit the expected spaces
        var receivedSpaces: [Space]?
        let cancellable = publisher
            .first()
            .sink { spaces in
                receivedSpaces = spaces
            }
        try await Task.sleep(for: .milliseconds(100))
        expect(receivedSpaces) == expectedSpaces
        cancellable.cancel()
    }

    func testExecuteWithEmptySpaces() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given no spaces in the gateway
        mockGateway.emitSpaces([])

        // When executing the use case
        let publisher = sut.execute()

        // Then it should emit an empty array
        var result: [Space]?
        let cancellable = publisher
            .first()
            .sink { spaces in
                result = spaces
            }
        try await Task.sleep(for: .milliseconds(100))
        expect(result).toNot(beNil())
        expect(result?.isEmpty) == true
        cancellable.cancel()
    }

    func testExecuteWithSingleSpace() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a single space in the gateway
        let expectedSpace = SpaceFixtures.focused
        mockGateway.emitSpaces([expectedSpace])

        // When executing the use case
        let publisher = sut.execute()

        // Then it should emit the single space
        var result: [Space]?
        let cancellable = publisher
            .first()
            .sink { spaces in
                result = spaces
            }
        try await Task.sleep(for: .milliseconds(100))
        expect(result?.count) == 1
        expect(result?.first?.id) == expectedSpace.id
        cancellable.cancel()
    }

    // MARK: - Reactive Behavior Tests

    func testPublisherEmitsUpdatesWhenGatewayChanges() async {
        guard let sut, let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given initial spaces
        let initialSpaces = [SpaceFixtures.basic]
        mockGateway.emitSpaces(initialSpaces)

        var receivedValues: [[Space]] = []
        let expectation = expectation(description: "Receive multiple values")
        expectation.expectedFulfillmentCount = 2

        // When subscribing to the publisher
        sut.execute()
            .sink { spaces in
                receivedValues.append(spaces)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // And then updating the gateway with new spaces
        try? await Task.sleep(for: .milliseconds(50))
        let updatedSpaces = [SpaceFixtures.basic, SpaceFixtures.focused]
        mockGateway.emitSpaces(updatedSpaces)

        // Then both values should be received
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedValues.count) == 2
        expect(receivedValues[0].count) == 1
        expect(receivedValues[1].count) == 2
    }

    func testMultipleSubscribersReceiveSameData() async {
        guard let sut, let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given spaces in the gateway
        let expectedSpaces = [SpaceFixtures.basic, SpaceFixtures.focused]
        mockGateway.emitSpaces(expectedSpaces)

        var subscriber1Values: [[Space]] = []
        var subscriber2Values: [[Space]] = []

        let expectation1 = expectation(description: "Subscriber 1 receives value")
        let expectation2 = expectation(description: "Subscriber 2 receives value")

        // When creating multiple subscribers
        let publisher = sut.execute()

        publisher
            .sink { spaces in
                subscriber1Values.append(spaces)
                expectation1.fulfill()
            }
            .store(in: &cancellables)

        publisher
            .sink { spaces in
                subscriber2Values.append(spaces)
                expectation2.fulfill()
            }
            .store(in: &cancellables)

        // Then both should receive the same data
        await fulfillment(of: [expectation1, expectation2], timeout: 1.0)
        expect(subscriber1Values.count) == 1
        expect(subscriber2Values.count) == 1
        expect(subscriber1Values.first?.count) == 2
        expect(subscriber2Values.first?.count) == 2
    }

    // MARK: - Data Integrity Tests

    func testExecutePreservesSpaceProperties() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a space with specific properties
        let customSpace = Space(
            id: "custom",
            isFocused: true,
            windows: [WindowFixtures.safari, WindowFixtures.vscode],
            colorProperties: ColorProperties(
                backgroundTintColor: Color(hex: "#FF0000") ?? .white,
                borderTintColor: .white,
                foregroundColor: .white
            ),
            geometricProperties: GeometricProperties(cornerRadius: 15.0, borderWidth: 0.0),
            effectProperties: EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 5.0, borderOpacity: 0.8)
        )
        mockGateway.emitSpaces([customSpace])

        // When executing the use case
        let publisher = sut.execute()

        // Then the space properties should be preserved
        var result: [Space]?
        let cancellable = publisher
            .first()
            .sink { spaces in
                result = spaces
            }
        try await Task.sleep(for: .milliseconds(100))
        expect(result?.first?.id) == "custom"
        expect(result?.first?.isFocused ?? false) == true
        expect(result?.first?.windows.count) == 2
        expect(result?.first?.colorProperties.backgroundTintColor.toHex()) == "#FF0000"
        expect(result?.first?.geometricProperties.cornerRadius) == 15.0
        expect(result?.first?.effectProperties.backgroundOpacity) == 0.8
        cancellable.cancel()
    }

    func testExecuteWithComplexSpacesStructure() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given spaces with various configurations
        let spaces = [
            SpaceFixtures.basic, // Empty space
            SpaceFixtures.focusedWithWindows, // Focused with windows
            SpaceFixtures.withCustomColors, // Custom colors
            SpaceFixtures.array(count: 3, focused: "2")[0] // From fixture array
        ]
        mockGateway.emitSpaces(spaces)

        // When executing the use case
        let publisher = sut.execute()

        // Then all spaces should be returned with correct structure
        var result: [Space]?
        let cancellable = publisher
            .first()
            .sink { spaces in
                result = spaces
            }
        try await Task.sleep(for: .milliseconds(100))
        expect(result?.count) == 4
        expect(result?[0].windows.isEmpty) == true
        expect(result?[1].isFocused ?? false) == true
        expect(result?[1].windows).toNot(beEmpty())
        expect(result?[2].colorProperties.backgroundTintColor.toHex()) == "#FF4245"
        cancellable.cancel()
    }

    // MARK: - Edge Cases Tests

    func testExecuteWithLargeNumberOfWindows() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a space with many windows
        let manyWindows = WindowFixtures.array(count: 50, workspace: "1")
        let space = Space(id: "1", windows: manyWindows)
        mockGateway.emitSpaces([space])

        // When executing the use case
        var result: [Space]?
        let cancellable = sut.execute()
            .first()
            .sink { spaces in
                result = spaces
            }
        try await Task.sleep(for: .milliseconds(100))

        // Then all windows should be included
        expect(result?.first?.windows.count) == 50
        cancellable.cancel()
    }

    func testExecuteHandlesSpecialCharactersInIds() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given spaces with special characters in IDs
        let specialSpaces = [
            Space(id: "space-with-dash"),
            Space(id: "space_with_underscore"),
            Space(id: "space.with.dots"),
            Space(id: "space/with/slashes")
        ]
        mockGateway.emitSpaces(specialSpaces)

        // When executing the use case
        var result: [Space]?
        let cancellable = sut.execute()
            .first()
            .sink { spaces in
                result = spaces
            }
        try await Task.sleep(for: .milliseconds(100))

        // Then all spaces should be returned correctly
        expect(result?.count) == 4
        expect(result?[0].id) == "space-with-dash"
        expect(result?[1].id) == "space_with_underscore"
        expect(result?[2].id) == "space.with.dots"
        expect(result?[3].id) == "space/with/slashes"
        cancellable.cancel()
    }

    // MARK: - Integration with Fixtures Tests

    func testWorksWithAllStandardFixtures() {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // When using standard fixtures
        let fixtures = [
            SpaceFixtures.basic,
            SpaceFixtures.focused,
            SpaceFixtures.withWindows,
            SpaceFixtures.focusedWithWindows,
            SpaceFixtures.withCustomColors
        ]

        for fixture in fixtures {
            // Given a fixture
            mockGateway.emitSpaces([fixture])

            // When executing the use case
            var result: [Space]?
            let cancellable = sut.execute()
                .first()
                .sink { spaces in
                    result = spaces
                }

            // Then it should work correctly
            expect(result?.count) == 1
            expect(result?.first?.id) == fixture.id
            cancellable.cancel()
        }
    }
}
