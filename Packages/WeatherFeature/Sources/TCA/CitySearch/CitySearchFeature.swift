import ComposableArchitecture
import CoreModels
import WeatherDomain

// MARK: - CitySearchFeature

@Reducer
public struct CitySearchFeature: Sendable {

    // MARK: - State

    @ObservableState
    public struct State: Sendable, Equatable {
        public var query: String = ""
        public var results: IdentifiedArrayOf<GeocodingResult> = []
        public var isSearching: Bool = false
        public var errorMessage: String?
        /// CityListFeature の登録済み都市 ID セット。RootFeature が同期する。
        public var addedCityIDs: Set<Int> = []

        public init() {}
    }

    // MARK: - Action

    public enum Action: Sendable, Equatable {
        case queryChanged(String)
        case searchResponse(Result<[GeocodingResult], WeatherError>)
        case addCityTapped(GeocodingResult)
        case delegate(Delegate)

        public enum Delegate: Sendable, Equatable {
            /// 都市の追加を RootFeature に通知する
            case cityAdded(GeocodingResult)
        }
    }

    // MARK: - CancelID

    private enum CancelID: Hashable {
        case search
    }

    // MARK: - Dependencies

    @Dependency(\.weatherRepository) var repository
    @Dependency(\.continuousClock) var clock

    // MARK: - Reducer

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .queryChanged(query):
                state.query = query
                state.errorMessage = nil
                guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                    state.results = []
                    state.isSearching = false
                    return .cancel(id: CancelID.search)
                }
                state.isSearching = true
                return .run { [query, repository, clock] send in
                    // 300ms debounce: cancelInFlight: true により前回タスクは自動キャンセル
                    try await clock.sleep(for: .milliseconds(300))
                    do {
                        let cities = try await repository.searchCities(name: query)
                        await send(.searchResponse(.success(cities)))
                    } catch let error as WeatherError {
                        await send(.searchResponse(.failure(error)))
                    } catch {
                        await send(.searchResponse(.failure(.networkFailure(error.localizedDescription))))
                    }
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)

            case let .searchResponse(.success(results)):
                state.isSearching = false
                state.results = IdentifiedArray(uniqueElements: results)
                return .none

            case let .searchResponse(.failure(error)):
                state.isSearching = false
                state.errorMessage = error.userMessage
                return .none

            case let .addCityTapped(result):
                return .send(.delegate(.cityAdded(result)))

            case .delegate:
                // 親 Feature (RootFeature) が処理する
                return .none
            }
        }
    }
}
