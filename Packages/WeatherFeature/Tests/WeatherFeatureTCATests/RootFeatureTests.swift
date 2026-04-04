import ComposableArchitecture
import CoreModels
import Foundation
import Testing
import WeatherDomain
@testable import WeatherFeatureTCA

enum RootFeatureTests {
    @MainActor
    private static func makeStore(
        initialState: RootFeature.State = .init(),
        defaults: UserDefaults = UserDefaults(suiteName: "test_\(UUID().uuidString)")!
    ) -> TestStore<RootFeature.State, RootFeature.Action> {
        TestStore(initialState: initialState) {
            RootFeature()
        } withDependencies: {
            $0.appSettingsService = AppSettingsService(defaults: defaults)
            $0.cityListService = CityListService(defaults: defaults)
            $0.weatherRepository = StubWeatherRepository()
            $0.locationService = StubLocationService()
            $0.continuousClock = TestClock()
        }
    }

    @MainActor
    struct TabTests {
        @Test("デフォルトタブは weather")
        func defaultTabIsWeather() {
            let state = RootFeature.State()
            #expect(state.selectedTab == .weather)
        }

        @Test("tabSelected で selectedTab が変わる（weather → city → settings → weather）")
        func tabSelectedChangesTab() async {
            let store = makeStore()
            await store.send(.tabSelected(.city)) {
                $0.selectedTab = .city
            }
            await store.send(.tabSelected(.settings)) {
                $0.selectedTab = .settings
            }
            await store.send(.tabSelected(.weather)) {
                $0.selectedTab = .weather
            }
        }
    }

    @MainActor
    struct SettingsTests {
        @Test("onAppear で永続化済み設定が読み込まれる")
        func onAppearLoadsSettings() async throws {
            let defaults = try #require(UserDefaults(suiteName: "test_\(UUID().uuidString)"))
            var settings = AppSettings.default
            settings.temperatureUnit = .fahrenheit
            AppSettingsService(defaults: defaults).save(settings)

            let store = makeStore(defaults: defaults)
            await store.send(.onAppear) {
                $0.settings.temperatureUnit = .fahrenheit
            }
        }

        @Test("settingsChanged で settings が更新・永続化される")
        func settingsChangedUpdatesAndPersists() async throws {
            let defaults = try #require(UserDefaults(suiteName: "test_\(UUID().uuidString)"))
            let store = makeStore(defaults: defaults)
            var newSettings = AppSettings.default
            newSettings.temperatureUnit = .fahrenheit

            await store.send(.settingsChanged(newSettings)) {
                $0.settings = newSettings
            }

            let loaded = AppSettingsService(defaults: defaults).load()
            #expect(loaded.temperatureUnit == .fahrenheit)
        }
    }

    @MainActor
    struct DelegateRoutingTests {
        @Test("CitySearch の cityAdded delegate が CityList.addCity に転送される")
        func cityAddedDelegateRouted() async throws {
            var initial = RootFeature.State()
            initial.cityPath.append(.citySearch(CitySearchFeature.State()))

            let store = makeStore(initialState: initial)
            store.exhaustivity = .off

            let result = GeocodingResult.stub(id: 42)
            try await store.send(.cityPath(.element(
                id: #require(initial.cityPath.ids.first),
                action: .citySearch(.delegate(.cityAdded(result)))
            )))
            await store.receive(.cityList(.addCity(result))) {
                $0.cityList.rows = [CityRowFeature.State(city: result.toCity())]
            }
        }
    }
}
