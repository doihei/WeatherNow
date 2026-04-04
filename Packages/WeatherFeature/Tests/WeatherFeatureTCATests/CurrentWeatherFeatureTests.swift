import ComposableArchitecture
import CoreModels
import Testing
import WeatherDomain
@testable import WeatherFeatureTCA

enum CurrentWeatherFeatureTests {
    @MainActor
    struct LoadTests {
        @Test("onAppear で viewState が loading になる")
        func onAppearSetsLoading() async {
            let store = TestStore(initialState: CurrentWeatherFeature.State()) {
                CurrentWeatherFeature()
            } withDependencies: {
                $0.locationService = StubLocationService()
                $0.weatherRepository = StubWeatherRepository()
            }
            store.exhaustivity = .off
            await store.send(.onAppear) {
                $0.viewState = .loading
            }
        }

        @Test("onAppear が成功すると viewState が loaded になる")
        func onAppearSuccessLoadsWeather() async {
            let weather = Weather.stub(temperature: 22.0)
            var repo = StubWeatherRepository()
            repo.weatherStub = weather
            let store = TestStore(initialState: CurrentWeatherFeature.State()) {
                CurrentWeatherFeature()
            } withDependencies: {
                $0.locationService = StubLocationService()
                $0.weatherRepository = repo
            }
            store.exhaustivity = .off
            await store.send(.onAppear)
            await store.receive(\.weatherResponse.success) {
                $0.viewState = .loaded(weather)
            }
        }

        @Test("onAppear が locationDenied エラーで viewState が error になる")
        func onAppearLocationDeniedSetsError() async {
            struct DeniedLocationService: LocationServiceProtocol {
                func requestCurrentLocation() async throws -> (latitude: Double, longitude: Double) {
                    throw WeatherError.locationDenied
                }
            }
            let store = TestStore(initialState: CurrentWeatherFeature.State()) {
                CurrentWeatherFeature()
            } withDependencies: {
                $0.locationService = DeniedLocationService()
                $0.weatherRepository = StubWeatherRepository()
            }
            store.exhaustivity = .off
            await store.send(.onAppear)
            await store.receive(\.weatherResponse.failure) {
                $0.viewState = .error(.locationDenied)
            }
        }

        @Test("onAppear がネットワークエラーで viewState が error になる")
        func onAppearNetworkErrorSetsError() async {
            struct FailingRepo: WeatherRepositoryProtocol {
                func fetchWeather(latitude _: Double, longitude _: Double) async throws -> Weather {
                    throw WeatherError.networkFailure("timeout")
                }

                func searchCities(name _: String) async throws -> [GeocodingResult] { [] }
                func clearCache() async {}
            }
            let store = TestStore(initialState: CurrentWeatherFeature.State()) {
                CurrentWeatherFeature()
            } withDependencies: {
                $0.locationService = StubLocationService()
                $0.weatherRepository = FailingRepo()
            }
            store.exhaustivity = .off
            await store.send(.onAppear)
            await store.receive(\.weatherResponse.failure) {
                $0.viewState = .error(.networkFailure("timeout"))
            }
        }

        @Test("loading 状態で onAppear を送っても Effect が発火しない")
        func onAppearIdempotentWhenLoading() async {
            var initial = CurrentWeatherFeature.State()
            initial.viewState = .loading
            let store = TestStore(initialState: initial) {
                CurrentWeatherFeature()
            }
            await store.send(.onAppear)
        }

        @Test("loaded 状態で onAppear を送っても Effect が発火しない")
        func onAppearIdempotentWhenLoaded() async {
            var initial = CurrentWeatherFeature.State()
            initial.viewState = .loaded(.stub())
            let store = TestStore(initialState: initial) {
                CurrentWeatherFeature()
            }
            await store.send(.onAppear)
        }
    }

    @MainActor
    struct RefreshTests {
        @Test("refresh で viewState が idle にリセットされる")
        func refreshResetsToIdle() async {
            var initial = CurrentWeatherFeature.State()
            initial.viewState = .loaded(.stub())
            let store = TestStore(initialState: initial) {
                CurrentWeatherFeature()
            } withDependencies: {
                $0.locationService = StubLocationService()
                $0.weatherRepository = StubWeatherRepository()
            }
            store.exhaustivity = .off
            await store.send(.refresh) {
                $0.viewState = .idle
            }
        }

        @Test("refresh 後に onAppear が送信され再ロードが始まる")
        func refreshTriggersReload() async {
            let weather = Weather.stub(temperature: 30.0)
            var repo = StubWeatherRepository()
            repo.weatherStub = weather
            var initial = CurrentWeatherFeature.State()
            initial.viewState = .loaded(.stub(temperature: 20.0))
            let store = TestStore(initialState: initial) {
                CurrentWeatherFeature()
            } withDependencies: {
                $0.locationService = StubLocationService()
                $0.weatherRepository = repo
            }
            store.exhaustivity = .off
            await store.send(.refresh) {
                $0.viewState = .idle
            }
            await store.receive(\.onAppear) {
                $0.viewState = .loading
            }
            await store.receive(\.weatherResponse.success) {
                $0.viewState = .loaded(weather)
            }
        }
    }

    @MainActor
    struct CityNameTests {
        @Test("cityNameResolved で cityName が更新される")
        func cityNameResolvedUpdatesCityName() async {
            let store = TestStore(initialState: CurrentWeatherFeature.State()) {
                CurrentWeatherFeature()
            }
            await store.send(.cityNameResolved("渋谷区")) {
                $0.cityName = "渋谷区"
            }
        }
    }
}
