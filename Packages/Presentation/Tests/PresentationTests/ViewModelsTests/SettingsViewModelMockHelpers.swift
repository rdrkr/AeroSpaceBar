// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation
@testable import Presentation

// MARK: - Mock Helpers

final class MockPublisherUseCase<T>: NSObject {
    private let subject: CurrentValueSubject<T, Never>

    init(value: T) {
        subject = CurrentValueSubject(value)
    }

    func execute() -> AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }

    func update(_ value: T) {
        subject.send(value)
    }
}

final class MockAsyncUseCase<T> {
    var lastValue: T?

    func execute(value: T) {
        lastValue = value
    }
}

final class MockAsyncVoidUseCase {
    func execute() { }
}
