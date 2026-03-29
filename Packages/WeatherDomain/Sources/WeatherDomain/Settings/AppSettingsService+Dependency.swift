import Dependencies
import Foundation

private enum AppSettingsServiceKey: DependencyKey {
    static let liveValue: any AppSettingsServiceProtocol = AppSettingsService()

    static var testValue: any AppSettingsServiceProtocol {
        AppSettingsService(defaults: UserDefaults(suiteName: "test_\(UUID().uuidString)")!)
    }
}

public extension DependencyValues {
    var appSettingsService: any AppSettingsServiceProtocol {
        get { self[AppSettingsServiceKey.self] }
        set { self[AppSettingsServiceKey.self] = newValue }
    }
}
