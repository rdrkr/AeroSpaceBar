// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Foundation

/// Mock implementation of SoftwareUpdateGateway for testing.
///
/// This mock allows tests to verify software update interactions and control
/// the values emitted by publishers.
@MainActor
public final class MockSoftwareUpdateGateway: SoftwareUpdateGateway {
    // MARK: - Call Tracking

    public private(set) var setAutomaticCheckForUpdatesEnabledCalls: [Bool] = []
    public private(set) var setAutomaticDownloadUpdatesEnabledCalls: [Bool] = []
    public private(set) var checkForUpdatesCalls: Int = 0

    // MARK: - Configurable Values

    private var _automaticCheckForUpdatesEnabledToEmit: Bool = true
    public var automaticCheckForUpdatesEnabledToEmit: Bool {
        get { _automaticCheckForUpdatesEnabledToEmit }
        set {
            _automaticCheckForUpdatesEnabledToEmit = newValue
            automaticCheckForUpdatesEnabledSubject.send(newValue)
        }
    }

    private var _automaticDownloadUpdatesEnabledToEmit: Bool = false
    public var automaticDownloadUpdatesEnabledToEmit: Bool {
        get { _automaticDownloadUpdatesEnabledToEmit }
        set {
            _automaticDownloadUpdatesEnabledToEmit = newValue
            automaticDownloadUpdatesEnabledSubject.send(newValue)
        }
    }

    private var _lastUpdateCheckDateToEmit: Date?
    public var lastUpdateCheckDateToEmit: Date? {
        get { _lastUpdateCheckDateToEmit }
        set {
            _lastUpdateCheckDateToEmit = newValue
            lastUpdateCheckDateSubject.send(newValue)
        }
    }

    // MARK: - Subjects

    private let automaticCheckForUpdatesEnabledSubject: CurrentValueSubject<Bool, Never>
    private let automaticDownloadUpdatesEnabledSubject: CurrentValueSubject<Bool, Never>
    private let lastUpdateCheckDateSubject: CurrentValueSubject<Date?, Never>

    // MARK: - Initialization

    public init() {
        automaticCheckForUpdatesEnabledSubject = CurrentValueSubject(_automaticCheckForUpdatesEnabledToEmit)
        automaticDownloadUpdatesEnabledSubject = CurrentValueSubject(_automaticDownloadUpdatesEnabledToEmit)
        lastUpdateCheckDateSubject = CurrentValueSubject(_lastUpdateCheckDateToEmit)
    }

    // MARK: - Publishers

    public var automaticCheckForUpdatesEnabledPublisher: AnyPublisher<Bool, Never> {
        automaticCheckForUpdatesEnabledSubject.eraseToAnyPublisher()
    }

    public var automaticDownloadUpdatesEnabledPublisher: AnyPublisher<Bool, Never> {
        automaticDownloadUpdatesEnabledSubject.eraseToAnyPublisher()
    }

    public var lastUpdateCheckDatePublisher: AnyPublisher<Date?, Never> {
        lastUpdateCheckDateSubject.eraseToAnyPublisher()
    }

    // MARK: - Methods

    public func setAutomaticCheckForUpdatesEnabled(_ enabled: Bool) {
        setAutomaticCheckForUpdatesEnabledCalls.append(enabled)
        automaticCheckForUpdatesEnabledToEmit = enabled
    }

    public func setAutomaticDownloadUpdatesEnabled(_ enabled: Bool) {
        setAutomaticDownloadUpdatesEnabledCalls.append(enabled)
        automaticDownloadUpdatesEnabledToEmit = enabled
    }

    public func checkForUpdates() {
        checkForUpdatesCalls += 1
        let newDate = Date()
        lastUpdateCheckDateToEmit = newDate
    }

    // MARK: - Test Helpers

    public func reset() {
        setAutomaticCheckForUpdatesEnabledCalls.removeAll()
        setAutomaticDownloadUpdatesEnabledCalls.removeAll()
        checkForUpdatesCalls = 0
    }

    public func emitAutomaticCheckForUpdatesEnabled(_ enabled: Bool) {
        automaticCheckForUpdatesEnabledSubject.send(enabled)
    }

    public func emitAutomaticDownloadUpdatesEnabled(_ enabled: Bool) {
        automaticDownloadUpdatesEnabledSubject.send(enabled)
    }

    public func emitLastUpdateCheckDate(_ date: Date?) {
        lastUpdateCheckDateSubject.send(date)
    }
}
