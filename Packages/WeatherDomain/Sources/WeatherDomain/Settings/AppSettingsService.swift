import CoreModels
import Foundation

// MARK: - AppSettingsService

/// UserDefaults を用いた AppSettings の永続化サービス。
/// UserDefaults は内部でスレッドセーフに動作するため @unchecked Sendable を付与する。
public struct AppSettingsService: AppSettingsServiceProtocol, @unchecked Sendable {
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load() -> AppSettings {
        AppSettings.load(from: defaults)
    }

    public func save(_ settings: AppSettings) {
        settings.save(to: defaults)
    }
}
