import ComposableArchitecture
import CoreModels
import Testing
import WeatherDomain
@testable import WeatherFeatureTCA

enum CitySearchFeatureTests {
    @MainActor
    struct DebounceTests {
        @Test("300ms 後に queryChanged で検索が実行される")
        func queryChangedTriggersSearchAfterDebounce() async {
            let clock = TestClock()
            let results = [GeocodingResult.stub(id: 1, name: "東京")]
            var repo = StubWeatherRepository()
            repo.searchStub = results

            let store = TestStore(initialState: CitySearchFeature.State()) {
                CitySearchFeature()
            } withDependencies: {
                $0.weatherRepository = repo
                $0.continuousClock = clock
            }

            await store.send(.queryChanged("東京")) {
                $0.query = "東京"
                $0.isSearching = true
            }
            await clock.advance(by: .milliseconds(300))
            await store.receive(.searchResponse(.success(results))) {
                $0.isSearching = false
                $0.results = IdentifiedArray(uniqueElements: results)
            }
        }

        @Test("300ms 以内に queryChanged を連続送信すると検索が1回だけ実行される")
        func rapidQueryChangesFireSearchOnce() async {
            let clock = TestClock()
            let results = [GeocodingResult.stub(id: 1, name: "大阪")]
            var repo = StubWeatherRepository()
            repo.searchStub = results

            let store = TestStore(initialState: CitySearchFeature.State()) {
                CitySearchFeature()
            } withDependencies: {
                $0.weatherRepository = repo
                $0.continuousClock = clock
            }

            await store.send(.queryChanged("大")) {
                $0.query = "大"
                $0.isSearching = true
            }
            await store.send(.queryChanged("大阪")) {
                $0.query = "大阪"
            }
            await clock.advance(by: .milliseconds(300))
            await store.receive(.searchResponse(.success(results))) {
                $0.isSearching = false
                $0.results = IdentifiedArray(uniqueElements: results)
            }
        }

        @Test("空文字を送ると results がクリアされ isSearching が false になる")
        func emptyQueryClearsResults() async {
            var initial = CitySearchFeature.State()
            initial.query = "東京"
            initial.results = IdentifiedArray(uniqueElements: [.stub(id: 1)])
            initial.isSearching = true

            let store = TestStore(initialState: initial) {
                CitySearchFeature()
            } withDependencies: {
                $0.continuousClock = TestClock()
            }

            await store.send(.queryChanged("")) {
                $0.query = ""
                $0.results = []
                $0.isSearching = false
            }
        }

        @Test("空白のみのクエリは検索を実行しない")
        func whitespaceOnlyQueryDoesNotSearch() async {
            let store = TestStore(initialState: CitySearchFeature.State()) {
                CitySearchFeature()
            } withDependencies: {
                $0.continuousClock = TestClock()
            }

            await store.send(.queryChanged("   ")) {
                $0.query = "   "
                $0.results = []
                $0.isSearching = false
            }
        }
    }

    @MainActor
    struct ErrorTests {
        @Test("検索エラーで isSearching が false になり errorMessage が設定される")
        func searchErrorSetsErrorMessage() async {
            let clock = TestClock()
            let store = TestStore(initialState: CitySearchFeature.State()) {
                CitySearchFeature()
            } withDependencies: {
                $0.weatherRepository = CitySearchFailingRepo()
                $0.continuousClock = clock
            }

            await store.send(.queryChanged("東京")) {
                $0.query = "東京"
                $0.isSearching = true
            }
            await clock.advance(by: .milliseconds(300))
            await store.receive(.searchResponse(.failure(.networkFailure("検索失敗")))) {
                $0.isSearching = false
                $0.errorMessage = WeatherError.networkFailure("検索失敗").userMessage
            }
        }

        @Test("queryChanged で errorMessage がクリアされる")
        func queryChangedClearsErrorMessage() async {
            var initial = CitySearchFeature.State()
            initial.errorMessage = "前回のエラー"

            let store = TestStore(initialState: initial) {
                CitySearchFeature()
            } withDependencies: {
                $0.continuousClock = TestClock()
            }
            // デバウンス中の Effect は検証対象外
            store.exhaustivity = .off
            await store.send(.queryChanged("東京")) {
                $0.query = "東京"
                $0.isSearching = true
                $0.errorMessage = nil
            }
        }
    }

    @MainActor
    struct DelegateTests {
        @Test("addCityTapped で delegate.cityAdded が送信される")
        func addCityTappedSendsDelegateAction() async {
            let result = GeocodingResult.stub(id: 1)
            let store = TestStore(initialState: CitySearchFeature.State()) {
                CitySearchFeature()
            } withDependencies: {
                $0.continuousClock = TestClock()
            }

            await store.send(.addCityTapped(result))
            await store.receive(.delegate(.cityAdded(result)))
        }
    }
}

private struct CitySearchFailingRepo: WeatherRepositoryProtocol {
    func fetchWeather(latitude _: Double, longitude _: Double) async throws -> Weather {
        .stub()
    }

    func searchCities(name _: String) async throws -> [GeocodingResult] {
        throw WeatherError.networkFailure("検索失敗")
    }

    func clearCache() async {}
}
