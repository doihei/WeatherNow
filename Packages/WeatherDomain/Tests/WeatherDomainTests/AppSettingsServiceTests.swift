import CoreModels
import Foundation
import Testing
@testable import WeatherDomain

struct AppSettingsServiceTests {
    @Test("空の UserDefaults からロードするとデフォルト値を返す")
    func loadFromEmptyReturnsDefault() throws {
        let defaults = try #require(UserDefaults(suiteName: "test_service_\(UUID().uuidString)"))
        let service = AppSettingsService(defaults: defaults)
        #expect(service.load() == AppSettings.default)
    }

    @Test("save した設定を load で取得できる", arguments: [
        AppSettings(temperatureUnit: .fahrenheit, windUnit: .mph, theme: .dark),
        AppSettings(temperatureUnit: .celsius, windUnit: .kmh, theme: .light),
    ])
    func saveLoadRoundTrip(settings: AppSettings) throws {
        let defaults = try #require(UserDefaults(suiteName: "test_service_\(UUID().uuidString)"))
        let service = AppSettingsService(defaults: defaults)
        service.save(settings)
        #expect(service.load() == settings)
    }

    @Test("異なる UserDefaults インスタンス間で設定が分離される")
    func isolatedDefaults() throws {
        let defaults1 = try #require(UserDefaults(suiteName: "test_service_a_\(UUID().uuidString)"))
        let defaults2 = try #require(UserDefaults(suiteName: "test_service_b_\(UUID().uuidString)"))
        let service1 = AppSettingsService(defaults: defaults1)
        let service2 = AppSettingsService(defaults: defaults2)

        let custom = AppSettings(temperatureUnit: .fahrenheit, windUnit: .mph, theme: .dark)
        service1.save(custom)

        #expect(service2.load() == AppSettings.default)
    }
}
