import CoreModels
import Dependencies
import Foundation
import Testing
@testable import WeatherFeatureMVVM

@MainActor
struct AppViewModelTests {
    private func makeSUT(settingsService: StubAppSettingsService = StubAppSettingsService()) -> AppViewModel {
        withDependencies {
            $0.weatherRepository = StubWeatherRepository()
            $0.locationService = StubLocationService()
            $0.appSettingsService = settingsService
            $0.cityListService = StubCityListService()
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

    @Test("loadSettings で settingsService から設定が読み込まれる")
    func loadSettingsLoadsFromService() {
        let saved = AppSettings(temperatureUnit: .fahrenheit, windUnit: .mph, theme: .dark)
        let service = StubAppSettingsService(settings: saved)
        let vm = makeSUT(settingsService: service)
        vm.loadSettings()
        #expect(vm.settings == saved)
    }

    // MARK: - saveSettings

    @Test("saveSettings で settingsService.save が呼ばれ保存される")
    func saveSettingsPersistsToService() {
        let service = StubAppSettingsService()
        let vm = makeSUT(settingsService: service)
        let newSettings = AppSettings(temperatureUnit: .fahrenheit, windUnit: .mph, theme: .dark)
        vm.settings = newSettings
        vm.saveSettings()
        #expect(service.savedSettings == newSettings)
    }

    @Test("saveSettings を呼ぶ前は savedSettings が nil")
    func saveNotCalledYieldNilSaved() {
        let service = StubAppSettingsService()
        _ = makeSUT(settingsService: service)
        #expect(service.savedSettings == nil)
    }

    // MARK: - makeCitySearchViewModel

    @Test("makeCitySearchViewModel は CitySearchViewModel を返す")
    func makeCitySearchViewModelReturnsCorrectType() {
        let vm = withDependencies {
            $0.weatherRepository = StubWeatherRepository()
            $0.locationService = StubLocationService()
            $0.appSettingsService = StubAppSettingsService()
            $0.cityListService = StubCityListService()
        } operation: {
            AppViewModel()
        }
        let searchVM = withDependencies {
            $0.weatherRepository = StubWeatherRepository()
        } operation: {
            vm.makeCitySearchViewModel()
        }
        _ = searchVM.query
        #expect(searchVM.results.isEmpty)
    }
}
