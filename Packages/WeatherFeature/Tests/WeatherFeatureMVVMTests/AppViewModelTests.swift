import CoreModels
import Foundation
import Testing
@testable import WeatherFeatureMVVM

@MainActor
struct AppViewModelTests {
    private func makeSUT(settingsService: StubAppSettingsService = StubAppSettingsService()) -> AppViewModel {
        UserDefaults.standard.removeObject(forKey: "registeredCities")
        return AppViewModel(
            repository: StubWeatherRepository(),
            locationService: StubLocationService(),
            settingsService: settingsService
        )
    }

    // MARK: - init

    @Test("init で settingsService から設定が読み込まれる")
    func initLoadsSettingsFromService() {
        let saved = AppSettings(temperatureUnit: .fahrenheit, windUnit: .mph, theme: .dark)
        let service = StubAppSettingsService(settings: saved)
        let vm = makeSUT(settingsService: service)
        #expect(vm.settings == saved)
    }

    @Test("init のデフォルト tab は .weather")
    func initDefaultTabIsWeather() {
        let vm = makeSUT()
        #expect(vm.selectedTab == .weather)
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
        let vm = makeSUT()
        let searchVM = vm.makeCitySearchViewModel()
        // CitySearchViewModel が返ってくること
        _ = searchVM.query // プロパティアクセスでコンパイル確認
        #expect(searchVM.results.isEmpty)
    }
}
