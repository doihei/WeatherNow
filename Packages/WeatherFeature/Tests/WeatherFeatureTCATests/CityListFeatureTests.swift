import ComposableArchitecture
import CoreModels
import Foundation
import Testing
import WeatherDomain
@testable import WeatherFeatureTCA

enum CityListFeatureTests {
    @MainActor
    private static func makeStore(
        initialState: CityListFeature.State = .init(),
        defaults: UserDefaults = UserDefaults(suiteName: "test_\(UUID().uuidString)")!,
        repository: any WeatherRepositoryProtocol = StubWeatherRepository()
    ) -> TestStore<CityListFeature.State, CityListFeature.Action> {
        TestStore(initialState: initialState) {
            CityListFeature()
        } withDependencies: {
            $0.cityListService = CityListService(defaults: defaults)
            $0.weatherRepository = repository
        }
    }

    @MainActor
    struct OnAppearTests {
        @Test("onAppear で永続化済み都市が rows に反映される")
        func onAppearLoadsCities() async throws {
            let defaults = try #require(UserDefaults(suiteName: "test_\(UUID().uuidString)"))
            let city1 = GeocodingResult.stub(id: 1, name: "東京").toCity()
            let city2 = GeocodingResult.stub(id: 2, name: "大阪").toCity()
            CityListService(defaults: defaults).save([city1, city2])

            let store = makeStore(defaults: defaults)
            await store.send(.onAppear) {
                $0.rows = IdentifiedArray(uniqueElements: [
                    CityRowFeature.State(city: city1),
                    CityRowFeature.State(city: city2),
                ])
            }
        }

        @Test("onAppear で永続化データがない場合は rows が空")
        func onAppearWithNoDataHasEmptyRows() async {
            let store = makeStore()
            await store.send(.onAppear)
        }
    }

    @MainActor
    struct AddCityTests {
        @Test("addCity で rows に都市が追加される")
        func addCityAppendsRow() async {
            let result = GeocodingResult.stub(id: 1)
            let store = makeStore()
            await store.send(.addCity(result)) {
                $0.rows = [CityRowFeature.State(city: result.toCity())]
            }
        }

        @Test("addCity で都市が永続化される")
        func addCityPersists() async throws {
            let defaults = try #require(UserDefaults(suiteName: "test_\(UUID().uuidString)"))
            let result = GeocodingResult.stub(id: 1)
            let store = makeStore(defaults: defaults)
            await store.send(.addCity(result)) {
                $0.rows = [CityRowFeature.State(city: result.toCity())]
            }
            let saved = CityListService(defaults: defaults).load()
            #expect(saved.count == 1)
            #expect(saved.first?.id == 1)
        }

        @Test("重複 id の都市は追加されない")
        func addCityDuplicateIsIgnored() async {
            var initial = CityListFeature.State()
            initial.rows = [CityRowFeature.State(city: GeocodingResult.stub(id: 1).toCity())]
            let store = makeStore(initialState: initial)
            await store.send(.addCity(.stub(id: 1)))
        }

        @Test("10件上限で addCity すると errorMessage が設定される")
        func addCityExceedsLimitSetsErrorMessage() async {
            var initial = CityListFeature.State()
            for i in 0 ..< 10 {
                initial.rows.append(CityRowFeature.State(city: GeocodingResult.stub(id: i).toCity()))
            }
            let store = makeStore(initialState: initial)
            await store.send(.addCity(.stub(id: 100))) {
                $0.errorMessage = WeatherError.cityLimitReached.userMessage
            }
        }
    }

    @MainActor
    struct RemoveCityTests {
        @Test("removeCity で rows から削除される")
        func removeCityDeletesRow() async {
            var initial = CityListFeature.State()
            initial.rows = [
                CityRowFeature.State(city: GeocodingResult.stub(id: 1).toCity()),
                CityRowFeature.State(city: GeocodingResult.stub(id: 2).toCity()),
            ]
            let store = makeStore(initialState: initial)
            await store.send(.removeCity(IndexSet(integer: 0))) {
                $0.rows = [CityRowFeature.State(city: GeocodingResult.stub(id: 2).toCity())]
            }
        }
    }

    @MainActor
    struct MoveCityTests {
        @Test("moveCity で rows の順序が変わる")
        func moveCityReordersRows() async {
            let city1 = GeocodingResult.stub(id: 1, name: "東京").toCity()
            let city2 = GeocodingResult.stub(id: 2, name: "大阪").toCity()
            var initial = CityListFeature.State()
            initial.rows = [
                CityRowFeature.State(city: city1),
                CityRowFeature.State(city: city2),
            ]
            let store = makeStore(initialState: initial)
            await store.send(.moveCity(IndexSet(integer: 0), 2)) {
                $0.rows = [
                    CityRowFeature.State(city: city2),
                    CityRowFeature.State(city: city1),
                ]
            }
        }
    }

    @MainActor
    struct ForEachTests {
        @Test("rows の CityRowFeature に onAppear を送ると天気を取得する")
        func rowForwardedOnAppearFetchesWeather() async {
            let weather = Weather.stub(temperature: 15.0)
            var repo = StubWeatherRepository()
            repo.weatherStub = weather
            let city = GeocodingResult.stub(id: 1).toCity()
            var initial = CityListFeature.State()
            initial.rows = [CityRowFeature.State(city: city)]

            let store = makeStore(initialState: initial, repository: repo)
            await store.send(.rows(.element(id: 1, action: .onAppear)))
            await store.receive(.rows(.element(id: 1, action: .weatherResponse(.success(weather))))) {
                $0.rows[id: 1]?.weather = weather
            }
        }
    }
}
