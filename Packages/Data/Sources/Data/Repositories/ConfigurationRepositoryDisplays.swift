// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation

/// Machine-local display preferences, independent of the portable TOML configuration.
public extension ConfigurationRepository {
    /// Observes this machine's spaces display selection.
    var spacesDisplayConfigurationPublisher: AnyPublisher<DisplayConfiguration, Never> {
        spacesDisplayPreferences.publisher
    }

    /// Observes this machine's groups display selection.
    var groupsDisplayConfigurationPublisher: AnyPublisher<DisplayConfiguration, Never> {
        groupsDisplayPreferences.publisher
    }

    /// Persists this machine's spaces display selection.
    func setSpacesDisplayConfiguration(_ value: DisplayConfiguration) {
        spacesDisplayPreferences.set(value)
    }

    /// Persists this machine's groups display selection.
    func setGroupsDisplayConfiguration(_ value: DisplayConfiguration) {
        groupsDisplayPreferences.set(value)
    }
}

/// Owns persistence and the private subject backing one display selection.
@MainActor
final class DisplayPreferences {
    private let defaults: UserDefaults
    private let key: String
    private let defaultValue: DisplayConfiguration
    private let subject: CurrentValueSubject<DisplayConfiguration, Never>

    /// Restores a display selection from this machine's preferences.
    /// - Parameters:
    ///   - key: The preference key storing the selection.
    ///   - defaultValue: The selection used when nothing valid is saved.
    ///   - defaults: The preference store.
    init(key: UserDefaultsKeys, defaultValue: DisplayConfiguration, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.key = key.rawValue
        self.defaultValue = defaultValue
        let saved = defaults.data(forKey: key.rawValue).flatMap { data in
            try? JSONDecoder().decode(DisplayConfiguration.self, from: data)
        }
        subject = CurrentValueSubject(saved ?? defaultValue)
    }

    /// The initial display selection and subsequent changes.
    var publisher: AnyPublisher<DisplayConfiguration, Never> {
        subject.eraseToAnyPublisher()
    }

    /// Saves the selection before notifying observers.
    func set(_ value: DisplayConfiguration) {
        guard
            value != subject.value,
            let data = try? JSONEncoder().encode(value) else { return }

        defaults.set(data, forKey: key)
        subject.send(value)
    }

    /// Restores primary-display behavior and clears the saved preference.
    func reset() {
        defaults.removeObject(forKey: key)
        subject.send(defaultValue)
    }
}
