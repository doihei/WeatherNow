import ComposableArchitecture
import CoreModels

// MARK: - HourlyChartFeature

@Reducer
public struct HourlyChartFeature: Sendable {
    // MARK: - State

    @ObservableState
    public struct State: Sendable, Equatable {
        public let hourlyForecasts: [HourlyForecast]

        public init(weather: Weather) {
            self.hourlyForecasts = weather.hourly
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
                .none
            }
        }
    }
}
