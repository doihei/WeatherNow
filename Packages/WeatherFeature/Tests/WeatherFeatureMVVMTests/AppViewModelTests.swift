import CoreModels
import Dependencies
import Foundation
import Testing
import WeatherDomain
@testable import WeatherFeatureMVVM

@MainActor
struct AppViewModelTests {
    private func makeSUT(
        appSettingsDefaults: UserDefaults = UserDefaults(suiteName: "test_\(UUID().uuidString)")!
    ) -> AppViewModel {
        withDependencies {
            $0.weatherRepository = StubWeatherRepository()
            $0.locationService = StubLocationService()
            $0.appSettingsService = AppSettingsService(defaults: appSettingsDefaults)
            $0.cityListService = CityListService(defaults: UserDefaults(suiteName: "test_\(UUID().uuidString)")!)
        } operation: {
            AppViewModel()
        }
    }

    // MARK: - init

    @Test("init のデフォルト tab は .weather")
    func initDefaultTabIsWeather() {
        let vm = makeSUT()
        #expect(vm.selectedTab == .weather)
    }

    @Test("init 直後の settings は .default")
    func initSettingsIsDefault() {
        let vm = makeSUT()
        #expect(vm.settings == .default)
    }

    // MARK: - loadSettings

    @Test("loadSettings で永続化済みの設定が読み込まれる")
    func loadSettingsLoadsPersistedSettings() throws {
        let saved = AppSettings(temperatureUnit: .fahrenheit, windUnit: .mph, theme: .dark)
        let defaults = try #require(UserDefaults(suiteName: "test_\(UUID().uuidString)"))
        saved.save(to: defaults)
        let vm = makeSUT(appSettingsDefaults: defaults)
        vm.loadSettings()
        #expect(vm.settings == saved)
    }

    // MARK: - saveSettings

    @Test("saveSettings で設定が永続化される")
    func saveSettingsPersists() throws {
        let defaults = try #require(UserDefaults(suiteName: "test_\(UUID().uuidString)"))
        let vm = makeSUT(appSettingsDefaults: defaults)
        let newSettings = AppSettings(temperatureUnit: .fahrenheit, windUnit: .mph, theme: .dark)
        vm.settings = newSettings
        vm.saveSettings()
        #expect(AppSettings.load(from: defaults) == newSettings)
    }

    @Test("saveSettings を呼ぶ前は設定が永続化されていない")
    func saveNotCalledYieldsDefaultPersistedSettings() throws {
        let defaults = try #require(UserDefaults(suiteName: "test_\(UUID().uuidString)"))
        _ = makeSUT(appSettingsDefaults: defaults)
        #expect(AppSettings.load(from: defaults) == .default)
    }

    // MARK: - makeCitySearchViewModel

    @Test("makeCitySearchViewModel は CitySearchViewModel を返す")
    func makeCitySearchViewModelReturnsCorrectType() {
        let vm = makeSUT()
        let searchVM = withDependencies {
            $0.weatherRepository = StubWeatherRepository()
        } operation: {
            vm.makeCitySearchViewModel()
        }
        _ = searchVM.query
        #expect(searchVM.results.isEmpty)
    }
}
