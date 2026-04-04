import ComposableArchitecture
import CoreModels
import WeatherDomain

// MARK: - Navigation Path Reducers

/// 天気タブの NavigationStack パス
@Reducer
public enum WeatherPath {
    case weeklyForecast(WeeklyForecastFeature)
}

extension WeatherPath.State: Equatable, Sendable {}
extension WeatherPath.Action: Sendable, Equatable {}

/// 都市タブの NavigationStack パス
@Reducer
public enum CityPath {
    case citySearch(CitySearchFeature)
}

extension CityPath.State: Equatable, Sendable {}
extension CityPath.Action: Sendable, Equatable {}

// MARK: - RootFeature

@Reducer
public struct RootFeature: Sendable {

    // MARK: - Tab

    public enum Tab: Sendable, Equatable {
        case weather
        case city
        case settings
    }

    // MARK: - State

    @ObservableState
    public struct State: Sendable, Equatable {
        public var selectedTab: Tab = .weather
        public var settings: AppSettings = .default

        // 天気タブ
        public var currentWeather: CurrentWeatherFeature.State = .init()
        public var weatherPath: StackState<WeatherPath.State> = .init()

        // 都市タブ
        public var cityList: CityListFeature.State = .init()
        public var cityPath: StackState<CityPath.State> = .init()

        public init() {}
    }

    // MARK: - Action

    public enum Action: Sendable, Equatable {
        case onAppear
        case tabSelected(Tab)
        case settingsChanged(AppSettings)

        // 天気タブ
        case currentWeather(CurrentWeatherFeature.Action)
        case weatherPath(StackActionOf<WeatherPath>)

        // 都市タブ
        case cityList(CityListFeature.Action)
        case cityPath(StackActionOf<CityPath>)
    }

    // MARK: - Dependencies

    @Dependency(\.appSettingsService) var appSettingsService

    // MARK: - Reducer

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.settings = appSettingsService.load()
                return .none

            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case let .settingsChanged(settings):
                state.settings = settings
                appSettingsService.save(settings)
                return .none

            // CitySearchFeature の delegate を CityListFeature に転送（疎結合）
            case let .cityPath(.element(id: _, action: .citySearch(.delegate(.cityAdded(result))))):
                return .send(.cityList(.addCity(result)))

            case .cityPath:
                return .none

            case .weatherPath:
                return .none

            case .currentWeather:
                return .none

            case .cityList:
                return .none
            }
        }
        Scope(state: \.currentWeather, action: \.currentWeather) {
            CurrentWeatherFeature()
        }
        .forEach(\.weatherPath, action: \.weatherPath)
        Scope(state: \.cityList, action: \.cityList) {
            CityListFeature()
        }
        .forEach(\.cityPath, action: \.cityPath)
    }
}
