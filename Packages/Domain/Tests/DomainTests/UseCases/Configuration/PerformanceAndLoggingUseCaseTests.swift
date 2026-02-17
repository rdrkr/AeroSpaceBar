// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for performance and logging configuration use cases.
///
/// These tests verify:
/// - GetEnablePerformanceMetricsUseCase
/// - SetEnablePerformanceMetricsUseCase
/// - GetOptimizedPerformanceEnabledUseCase
/// - SetOptimizedPerformanceEnabledUseCase
/// - GetLogLevelUseCase
/// - SetLogLevelUseCase
@MainActor
final class PerformanceAndLoggingUseCaseTests: XCTestCase {
    private var mockGateway: MockConfigurationGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockConfigurationGateway()
        cancellables = []
    }

    // MARK: - EnablePerformanceMetrics Tests

    func testGetEnablePerformanceMetrics() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = GetEnablePerformanceMetricsUseCase(configurationGateway: mockGateway)
        var receivedValue: Bool?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.enablePerformanceMetricsToEmit
    }

    func testSetEnablePerformanceMetrics() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetEnablePerformanceMetricsUseCase(configurationGateway: mockGateway)
        let newValue = true

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setEnablePerformanceMetricsCalls.last) == newValue
    }

    func testSetEnablePerformanceMetricsWithNilDefaultsToTrue() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetEnablePerformanceMetricsUseCase(configurationGateway: mockGateway)

        // When
        await useCase.execute(value: nil)

        // Then
        expect(mockGateway.setEnablePerformanceMetricsCalls.last) == true
        expect(Logger.enablePerformanceMetrics) == true
    }

    // MARK: - OptimizedPerformanceEnabled Tests

    func testGetOptimizedPerformanceEnabled() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = GetOptimizedPerformanceEnabledUseCase(configurationGateway: mockGateway)
        var receivedValue: Bool?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.isOptimizedPerformanceEnabledToEmit
    }

    func testSetOptimizedPerformanceEnabled() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetOptimizedPerformanceEnabledUseCase(configurationGateway: mockGateway)
        let newValue = true

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setIsOptimizedPerformanceEnabledCalls.last) == newValue
    }

    // MARK: - LogLevel Tests

    func testGetLogLevel() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = GetLogLevelUseCase(configurationGateway: mockGateway)
        var receivedValue: Logger.Level?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.logLevelToEmit
    }

    func testSetLogLevel() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetLogLevelUseCase(configurationGateway: mockGateway)
        let newValue: Logger.Level = .debug

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setLogLevelCalls.last) == newValue
    }

    func testSetLogLevelWithNilDefaultsToInfo() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetLogLevelUseCase(configurationGateway: mockGateway)

        // When
        await useCase.execute(value: nil)

        // Then
        expect(mockGateway.setLogLevelCalls.last) == .info
        expect(Logger.logLevel) == .info
    }
}
