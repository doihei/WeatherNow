import ComposableArchitecture
import CoreModels
import Testing
import WeatherDomain
@testable import WeatherFeatureTCA

enum CityRowFeatureTests {
    @MainActor
    struct LoadTests {
        @Test("onAppear で weather が取得される")
        func onAppearFetchesWeather() async {
            let weather = Weather.stub(temperature: 18.0)
            var repo = StubWeatherRepository()
            repo.weatherStub = weather
            let city = GeocodingResult.stub(id: 1).toCity()
            let store = TestStore(initialState: CityRowFeature.State(city: city)) {
                CityRowFeature()
            } withDependencies: {
                $0.weatherRepository = repo
            }
            await store.send(.onAppear)
            await store.receive(.weatherResponse(.success(weather))) {
                $0.weather = weather
            }
        }

        @Test("weather が既存の場合は onAppear で再フェッチしない")
        func onAppearIdempotentWhenWeatherExists() async {
            let existing = Weather.stub(temperature: 25.0)
            let city = GeocodingResult.stub(id: 1).toCity()
            let state = CityRowFeature.State(city: city, weather: existing)
            let store = TestStore(initialState: state) {
                CityRowFeature()
            }
            await store.send(.onAppear)
        }

        @Test("fetchWeather 失敗時は State が変化しない")
        func fetchWeatherFailureLeavesStateUnchanged() async {
            struct FailingRepo: WeatherRepositoryProtocol {
                func fetchWeather(latitude _: Double, longitude _: Double) async throws -> Weather {
                    throw WeatherError.networkFailure("error")
                }

                func searchCities(name _: String) async throws -> [GeocodingResult] { [] }
                func clearCache() async {}
            }
            let city = GeocodingResult.stub(id: 1).toCity()
            let store = TestStore(initialState: CityRowFeature.State(city: city)) {
                CityRowFeature()
            } withDependencies: {
                $0.weatherRepository = FailingRepo()
            }
            await store.send(.onAppear)
            await store.receive(.weatherResponse(.failure(.networkFailure("error"))))
            // weather は nil のまま（State は変化しない）
        }
    }
}
