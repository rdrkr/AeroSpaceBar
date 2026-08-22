// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.
// Modifications Copyright (c) 2026 Jakub Kubiak.
// Modified 2026-08-22 by Jakub Kubiak: Added real-time AeroSpace event coverage.

import AppKit
import Combine
@testable import Data
@testable import Domain
import Nimble
import XCTest

@MainActor
final class AeroSpaceRepositoryTests: XCTestCase {
    private var repository: AeroSpaceRepository?
    private var mockIconCache: MockIconCache?
    private var mockCLIFactory: MockAeroSpaceCLIClientFactory?
    private var mockCLIClient: MockAeroSpaceCLIClient?
    private var mockEventClient: MockAeroSpaceEventClient?
    private var mockCommandExecutor: MockCommandExecutor?
    private var mockRunningAppChecker: MockRunningAppChecker?
    private var mockConfigGateway: MockConfigurationGateway?
    private var cancellables: Set<AnyCancellable>?

    // Mock Use Cases
    private var getAeroSpacePathUseCase: GetAeroSpacePathUseCase?
    private var getAeroSpaceConfigPathUseCase: GetAeroSpaceConfigPathUseCase?
    private var getOptimizedPerformanceEnabledUseCase: GetOptimizedPerformanceEnabledUseCase?
    private var getSpacesColorPropertiesUseCase: GetSpacesColorPropertiesUseCase?

    override func setUp() async throws {
        try await super.setUp()
        mockIconCache = MockIconCache()
        mockCLIFactory = MockAeroSpaceCLIClientFactory()
        // Use the client instance from the factory so we can verify calls on it
        mockCLIClient = mockCLIFactory?.mockClient as? MockAeroSpaceCLIClient
        mockEventClient = MockAeroSpaceEventClient()

        mockCommandExecutor = MockCommandExecutor()
        mockRunningAppChecker = MockRunningAppChecker()
        mockConfigGateway = MockConfigurationGateway()
        cancellables = []

        guard let mockConfigGateway else { return }

        getAeroSpacePathUseCase = GetAeroSpacePathUseCase(configurationGateway: mockConfigGateway)
        getAeroSpaceConfigPathUseCase = GetAeroSpaceConfigPathUseCase(configurationGateway: mockConfigGateway)
        getOptimizedPerformanceEnabledUseCase =
            GetOptimizedPerformanceEnabledUseCase(configurationGateway: mockConfigGateway)
        getSpacesColorPropertiesUseCase = GetSpacesColorPropertiesUseCase(configurationGateway: mockConfigGateway)

        guard
            let mockIconCache, let getAeroSpacePathUseCase, let getAeroSpaceConfigPathUseCase,
            let getOptimizedPerformanceEnabledUseCase, let getSpacesColorPropertiesUseCase, let mockCLIFactory,
            let mockEventClient,
            let mockCommandExecutor, let mockRunningAppChecker else { return }

        repository = AeroSpaceRepository(
            iconCache: mockIconCache,
            getAeroSpacePathUseCase: getAeroSpacePathUseCase,
            getAeroSpaceConfigPathUseCase: getAeroSpaceConfigPathUseCase,
            getOptimizedPerformanceEnabledUseCase: getOptimizedPerformanceEnabledUseCase,
            getSpacesColorPropertiesUseCase: getSpacesColorPropertiesUseCase,
            cliFactory: mockCLIFactory,
            eventClient: mockEventClient,
            commandExecutor: mockCommandExecutor,
            runningAppChecker: mockRunningAppChecker
        )
    }

    override func tearDown() async throws {
        repository = nil
        mockIconCache = nil
        mockCLIFactory = nil
        mockCLIClient = nil
        mockEventClient = nil
        mockCommandExecutor = nil
        mockRunningAppChecker = nil
        mockConfigGateway = nil
        cancellables = nil
        getAeroSpacePathUseCase = nil
        getAeroSpaceConfigPathUseCase = nil
        getOptimizedPerformanceEnabledUseCase = nil
        getSpacesColorPropertiesUseCase = nil
        try await super.tearDown()
    }

    func testFocusSpaceSuccess() async throws {
        guard let repository, let mockCLIClient else {
            XCTFail("Dependencies not initialized")
            return
        }

        mockCLIClient.executeResult = .success(Data())
        try await repository.focusSpace(spaceId: "1", needWindowFocus: false)
        expect(mockCLIClient.executedArguments).toNot(beNil())
        expect(mockCLIClient.executedArguments).to(contain("workspace"))
        expect(mockCLIClient.executedArguments).to(contain("1"))
    }

    func testFocusSpaceFailure() async {
        guard let repository, let mockCLIClient else {
            XCTFail("Dependencies not initialized")
            return
        }

        mockCLIClient.executeResult = .failure(NSError(domain: "Test", code: -1))
        do {
            try await repository.focusSpace(spaceId: "1", needWindowFocus: false)
            XCTFail("Should throw error")
        } catch {
            expect(error).toNot(beNil())
        }
    }

    func testFocusWindowSuccess() async throws {
        guard let repository, let mockCLIClient else {
            XCTFail("Dependencies not initialized")
            return
        }

        mockCLIClient.executeResult = .success(Data())
        try await repository.focusWindow(windowId: "123")
        expect(mockCLIClient.executedArguments).toNot(beNil())
        expect(mockCLIClient.executedArguments).to(contain("focus"))
        expect(mockCLIClient.executedArguments).to(contain("--window-id"))
        expect(mockCLIClient.executedArguments).to(contain("123"))
    }

    func testFocusWindowFailure() async {
        guard let repository, let mockCLIClient else {
            XCTFail("Dependencies not initialized")
            return
        }

        mockCLIClient.executeResult = .failure(NSError(domain: "Test", code: -1))
        do {
            try await repository.focusWindow(windowId: "123")
            XCTFail("Should throw error")
        } catch {
            expect(error).toNot(beNil())
        }
    }

    func testStartAeroSpaceWhenNotRunning() async throws {
        guard let repository, let mockRunningAppChecker, let mockCommandExecutor else {
            XCTFail("Dependencies not initialized")
            return
        }

        mockRunningAppChecker.isRunningResult = false
        mockCommandExecutor.runResult = .success(())
        try await repository.startAeroSpace()
        expect(mockCommandExecutor.runCalled).to(beTrue())
    }

    func testStartAeroSpaceWhenAlreadyRunning() async throws {
        guard let repository, let mockRunningAppChecker, let mockCommandExecutor else {
            XCTFail("Dependencies not initialized")
            return
        }

        mockRunningAppChecker.isRunningResult = true
        try await repository.startAeroSpace()
        expect(mockCommandExecutor.runCalled).to(beFalse())
    }

    func testStartAeroSpaceFailure() async {
        guard let repository, let mockRunningAppChecker, let mockCommandExecutor else {
            XCTFail("Dependencies not initialized")
            return
        }

        mockRunningAppChecker.isRunningResult = false
        mockCommandExecutor.runResult = .failure(NSError(domain: "Test", code: -1))
        do {
            try await repository.startAeroSpace()
            XCTFail("Should throw error")
        } catch {
            expect(error).toNot(beNil())
        }
    }

    func testAeroSpaceRunningPublisher() {
        guard let repository else {
            XCTFail("Dependencies not initialized")
            return
        }

        // Just verify it returns a publisher
        _ = repository.aeroSpaceRunningPublisher
    }

    func testSpacesWithWindowsPublisher() {
        guard let repository else {
            XCTFail("Dependencies not initialized")
            return
        }

        // Just verify it returns a publisher
        _ = repository.spacesWithWindowsPublisher
    }
}
