// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation

/// Mock implementation of SpacesGateway for testing.
///
/// This mock allows tests to control the spaces data and verify interactions
/// without requiring a real AeroSpace installation.
@MainActor
public final class MockSpacesGateway: SpacesGateway {
    // MARK: - Configurable Test Data

    /// Spaces to be emitted by the publisher
    public var spacesToEmit: [Space] = []

    /// Whether AeroSpace is running
    public var isAeroSpaceRunning: Bool = true {
        didSet {
            aeroSpaceRunningSubject.send(isAeroSpaceRunning)
        }
    }

    /// Errors to throw for specific operations
    public var focusSpaceError: AppError?
    public var focusWindowError: AppError?
    public var startAeroSpaceError: AppError?

    /// Whether to throw an error when focusWindow is called (for test compatibility)
    public var shouldThrowOnFocus: Bool = false

    /// Whether to throw an error when startAeroSpace is called (for test compatibility)
    public var shouldThrowOnStartAeroSpace: Bool = false

    // MARK: - Call Tracking

    /// Tracks calls to focusSpace with their parameters
    public private(set) var focusSpaceCalls: [(spaceId: String, needWindowFocus: Bool)] = []

    /// Tracks calls to focusWindow with their parameters
    public private(set) var focusWindowCalls: [String] = []

    /// Tracks calls to startAeroSpace
    public private(set) var startAeroSpaceCallCount: Int = 0

    // MARK: - Publishers

    private let spacesSubject = CurrentValueSubject<[Space], Never>([])
    private let aeroSpaceRunningSubject = CurrentValueSubject<Bool, Never>(true)

    public var spacesWithWindowsPublisher: AnyPublisher<[Space], Never> {
        spacesSubject.eraseToAnyPublisher()
    }

    public var aeroSpaceRunningPublisher: AnyPublisher<Bool, Never> {
        aeroSpaceRunningSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    public init() { }

    // MARK: - Gateway Methods

    public func focusSpace(spaceId: String, needWindowFocus: Bool) throws {
        focusSpaceCalls.append((spaceId: spaceId, needWindowFocus: needWindowFocus))

        if shouldThrowOnFocus {
            throw AppError.aeroSpaceNotRunning
        }

        if let error = focusSpaceError {
            throw error
        }

        // Update focus state in spacesToEmit
        for i in 0 ..< spacesToEmit.count {
            spacesToEmit[i].isFocused = (spacesToEmit[i].id == spaceId)
        }
        spacesSubject.send(spacesToEmit)
    }

    public func focusWindow(windowId: String) throws {
        focusWindowCalls.append(windowId)

        if shouldThrowOnFocus {
            throw AppError.aeroSpaceNotRunning
        }

        if let error = focusWindowError {
            throw error
        }

        // Update focus state in spacesToEmit
        for i in 0 ..< spacesToEmit.count {
            for j in 0 ..< spacesToEmit[i].windows.count {
                spacesToEmit[i].windows[j].isFocused = (String(spacesToEmit[i].windows[j].id) == windowId)
            }
        }
        spacesSubject.send(spacesToEmit)
    }

    public func startAeroSpace() throws {
        startAeroSpaceCallCount += 1

        if shouldThrowOnStartAeroSpace {
            throw AppError.aeroSpaceNotRunning
        }

        if let error = startAeroSpaceError {
            throw error
        }

        // Update running status
        isAeroSpaceRunning = true
        aeroSpaceRunningSubject.send(true)
    }

    // MARK: - Test Helper Methods

    /// Emits spaces through the publisher
    public func emitSpaces(_ spaces: [Space]) {
        spacesToEmit = spaces
        spacesSubject.send(spaces)
    }

    /// Sets the AeroSpace running status
    public func setAeroSpaceRunning(_ isRunning: Bool) {
        isAeroSpaceRunning = isRunning
    }

    /// Resets all tracked calls
    public func reset() {
        focusSpaceCalls.removeAll()
        focusWindowCalls.removeAll()
        startAeroSpaceCallCount = 0
        focusSpaceError = nil
        focusWindowError = nil
        startAeroSpaceError = nil
    }
}
