import Foundation
import Testing
@testable import CoreModels

enum AppSettingsTests {
    // MARK: - TemperatureUnit

    struct TemperatureUnitTests {
        @Test("celsius は変換なし")
        func celsiusIdentity() {
            #expect(AppSettings.TemperatureUnit.celsius.convert(0) == 0)
            #expect(AppSettings.TemperatureUnit.celsius.convert(100) == 100)
            #expect(AppSettings.TemperatureUnit.celsius.convert(-40) == -40)
        }

        @Test("fahrenheit 変換式が正しい（0℃→32℉, 100℃→212℉, -40℃→-40℉）", arguments: zip(
            [0.0, 100.0, -40.0],
            [32.0, 212.0, -40.0]
        ))
        func fahrenheitConversion(celsius: Double, expected: Double) {
            #expect(AppSettings.TemperatureUnit.fahrenheit.convert(celsius) == expected)
        }

        @Test("symbol が正しい")
        func symbol() {
            #expect(AppSettings.TemperatureUnit.celsius.symbol == "℃")
            #expect(AppSettings.TemperatureUnit.fahrenheit.symbol == "℉")
        }
    }

    // MARK: - WindUnit

    struct WindUnitTests {
        @Test("kmh は変換なし")
        func kmhIdentity() {
            #expect(AppSettings.WindUnit.kmh.convert(0) == 0)
            #expect(AppSettings.WindUnit.kmh.convert(100) == 100)
        }

        @Test("mph 変換が正しい（100km/h → 約62.14mph）")
        func mphConversion() {
            let result = AppSettings.WindUnit.mph.convert(100)
            #expect(abs(result - 62.1371) < 0.001)
        }

        @Test("0km/h → 0mph")
        func zeroConversion() {
            #expect(AppSettings.WindUnit.mph.convert(0) == 0)
        }

        @Test("symbol が正しい")
        func symbol() {
            #expect(AppSettings.WindUnit.kmh.symbol == "km/h")
            #expect(AppSettings.WindUnit.mph.symbol == "mph")
        }
    }

    // MARK: - Theme

    struct ThemeTests {
        @Test("displayName が正しい", arguments: zip(
            [AppSettings.Theme.system, .light, .dark],
            ["システム", "ライト", "ダーク"]
        ))
        func displayName(theme: AppSettings.Theme, expected: String) {
            #expect(theme.displayName == expected)
        }
    }

    // MARK: - Default & Persistence

    struct PersistenceTests {
        @Test(".default が正しい初期値を持つ")
        func defaultValues() {
            let settings = AppSettings.default
            #expect(settings.temperatureUnit == .celsius)
            #expect(settings.windUnit == .kmh)
            #expect(settings.theme == .system)
        }

        @Test("save/load ラウンドトリップ", arguments: [
            AppSettings(temperatureUnit: .fahrenheit, windUnit: .mph, theme: .dark),
            AppSettings(temperatureUnit: .celsius, windUnit: .kmh, theme: .light),
        ])
        func saveLoadRoundTrip(settings: AppSettings) throws {
            let defaults = try #require(UserDefaults(suiteName: "test_roundtrip_\(UUID().uuidString)"))
            settings.save(to: defaults)
            let loaded = AppSettings.load(from: defaults)
            #expect(loaded == settings)
        }

        @Test("未設定の UserDefaults からロードするとデフォルト値を返す")
        func loadFromEmptyDefaults() throws {
            let defaults = try #require(UserDefaults(suiteName: "test_empty_\(UUID().uuidString)"))
            let loaded = AppSettings.load(from: defaults)
            #expect(loaded == AppSettings.default)
        }
    }
}
