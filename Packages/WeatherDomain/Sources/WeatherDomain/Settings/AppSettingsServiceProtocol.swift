import CoreModels

// MARK: - AppSettingsServiceProtocol

public protocol AppSettingsServiceProtocol: Sendable {
    func load() -> AppSettings
    func save(_ settings: AppSettings)
}
