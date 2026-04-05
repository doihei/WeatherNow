import CoreModels
import Dependencies
import SwiftUI
import WeatherDomain

// MARK: - Navigation Destinations

/// 天気タブの NavigationPath 行先
public enum WeatherDestination: Hashable, Sendable {
    case weeklyForecast
    case hourlyChart
}

/// 都市タブの NavigationPath 行先
public enum CityDestination: Hashable, Sendable {
    case search
}

// MARK: - AppViewModel

@MainActor
@Observable
public final class AppViewModel {
    // MARK: - Tab

    public enum Tab {
        case weather
        case city
        case settings
    }

    // MARK: - Navigation State

    public var selectedTab: Tab = .weather
    public var weatherPath = NavigationPath()
    public var cityPath = NavigationPath()

    // MARK: - Settings

    public var settings: AppSettings = .default

    // MARK: - Child ViewModels

    public let currentWeatherViewModel: CurrentWeatherViewModel
    public let cityListViewModel: CityListViewModel

    // MARK: - Dependencies

    @ObservationIgnored
    @Dependency(\.appSettingsService) private var settingsService

    // MARK: - Init

    public init() {
        self.cityListViewModel = CityListViewModel()
        self.currentWeatherViewModel = CurrentWeatherViewModel()
    }

    // MARK: - Settings

    /// 永続化された設定を読み込む。View の .task / .onAppear から呼ぶ。
    public func loadSettings() {
        settings = settingsService.load()
    }

    public func saveSettings() {
        settingsService.save(settings)
    }

    // MARK: - Factory

    public func makeCitySearchViewModel() -> CitySearchViewModel {
        CitySearchViewModel(cityListViewModel: cityListViewModel)
    }
}
