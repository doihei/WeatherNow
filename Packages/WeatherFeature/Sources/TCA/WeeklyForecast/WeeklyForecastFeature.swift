import ComposableArchitecture
import CoreModels

// MARK: - WeeklyForecastFeature

@Reducer
public struct WeeklyForecastFeature: Sendable {

    // MARK: - State

    @ObservableState
    public struct State: Sendable, Equatable {
        public let dailyForecasts: [DailyForecast]

        public init(weather: Weather) {
            self.dailyForecasts = weather.daily
        }
    }

    // MARK: - Action

    public enum Action: Sendable, Equatable {
        /// 将来の拡張用。現状は副作用なし。
        case onAppear
    }

    // MARK: - Reducer

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
