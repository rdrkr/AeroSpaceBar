// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation

/// Machine-local spaces display preferences, independent of the portable TOML configuration.
public extension ConfigurationRepository {
    /// Observes this machine's spaces display selection.
    var spacesDisplayConfigurationPublisher: AnyPublisher<SpacesDisplayConfiguration, Never> {
        spacesDisplayPreferences.publisher
    }

    /// Persists this machine's display selection.
    func setSpacesDisplayConfiguration(_ value: SpacesDisplayConfiguration) {
        spacesDisplayPreferences.set(value)
    }
}

/// Owns persistence and the private subject backing display selection.
@MainActor
final class SpacesDisplayPreferences {
    private let defaults: UserDefaults
    private let key = UserDefaultsKeys.spacesDisplayConfiguration.rawValue
    private let subject: CurrentValueSubject<SpacesDisplayConfiguration, Never>

    /// Restores display selection from this machine's preferences.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let saved = defaults.data(forKey: key).flatMap { data in
            try? JSONDecoder().decode(SpacesDisplayConfiguration.self, from: data)
        }
        subject = CurrentValueSubject(saved ?? ConfigurationDefaults.spacesDisplayConfiguration)
    }

    /// The initial display selection and subsequent changes.
    var publisher: AnyPublisher<SpacesDisplayConfiguration, Never> {
        subject.eraseToAnyPublisher()
    }

    /// Saves the selection before notifying observers.
    func set(_ value: SpacesDisplayConfiguration) {
        guard
            value != subject.value,
            let data = try? JSONEncoder().encode(value) else { return }

        defaults.set(data, forKey: key)
        subject.send(value)
    }

    /// Restores primary-display behavior and clears the saved preference.
    func reset() {
        defaults.removeObject(forKey: key)
        subject.send(ConfigurationDefaults.spacesDisplayConfiguration)
    }
}
