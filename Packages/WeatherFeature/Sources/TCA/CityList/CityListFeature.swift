import ComposableArchitecture
import CoreModels
import Foundation
import WeatherDomain

// MARK: - CityListFeature

@Reducer
public struct CityListFeature: Sendable {
    // MARK: - State

    @ObservableState
    public struct State: Sendable, Equatable {
        public var rows: IdentifiedArrayOf<CityRowFeature.State> = []
        public var errorMessage: String?

        public init() {}
    }

    // MARK: - Action

    public enum Action: Sendable, Equatable {
        case onAppear
        case refresh
        /// CitySearchFeature の delegate 経由で呼ばれる（上限10件・重複チェックあり）
        case addCity(GeocodingResult)
        case removeCity(IndexSet)
        case moveCity(IndexSet, Int)
        /// .forEach で CityRowFeature の Action を転送する
        case rows(IdentifiedActionOf<CityRowFeature>)
        /// 都市検索画面へのナビゲーション（RootFeature が処理する）
        case showCitySearch
    }

    // MARK: - Dependencies

    @Dependency(\.cityListService) var cityListService

    // MARK: - Reducer

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let cities = cityListService.load()
                let existing = state.rows
                state.rows = IdentifiedArray(
                    uniqueElements: cities.map { city in
                        existing[id: city.id] ?? CityRowFeature.State(city: city)
                    }
                )
                return .none

            case .refresh:
                let cities = cityListService.load()
                state.rows = IdentifiedArray(
                    uniqueElements: cities.map { CityRowFeature.State(city: $0) }
                )
                let ids = state.rows.map(\.id)
                return .merge(ids.map { id in
                    .send(.rows(.element(id: id, action: .onAppear)))
                })

            case let .addCity(result):
                guard state.rows.count < 10 else {
                    state.errorMessage = WeatherError.cityLimitReached.userMessage
                    return .none
                }
                guard !state.rows.contains(where: { $0.id == result.id }) else { return .none }
                state.rows.append(CityRowFeature.State(city: result.toCity()))
                cityListService.save(state.rows.map(\.city))
                return .none

            case let .removeCity(offsets):
                state.rows.remove(atOffsets: offsets)
                cityListService.save(state.rows.map(\.city))
                return .none

            case let .moveCity(source, destination):
                state.rows.move(fromOffsets: source, toOffset: destination)
                cityListService.save(state.rows.map(\.city))
                return .none

            case .rows:
                // .forEach が各 CityRowFeature に Action を転送する
                return .none

            case .showCitySearch:
                // RootFeature が CityPath への push を処理する
                return .none
            }
        }
        // 各行の天気取得を CityRowFeature に委譲する
        .forEach(\.rows, action: \.rows) {
            CityRowFeature()
        }
    }
}
