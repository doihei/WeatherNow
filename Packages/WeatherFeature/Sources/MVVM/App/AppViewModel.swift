import CoreModels
import SwiftUI
import WeatherDomain

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

    public var settings: AppSettings

    // MARK: - Child ViewModels

    public let currentWeatherViewModel: CurrentWeatherViewModel
    public let cityListViewModel: CityListViewModel

    // MARK: - Dependencies

    private let repository: any WeatherRepositoryProtocol
    private let locationService: any LocationServiceProtocol
    private let settingsService: any AppSettingsServiceProtocol

    // MARK: - Init

    public init(
        repository: any WeatherRepositoryProtocol,
        locationService: any LocationServiceProtocol,
        settingsService: any AppSettingsServiceProtocol = AppSettingsService()
    ) {
        self.repository = repository
        self.locationService = locationService
        self.settingsService = settingsService
        self.settings = settingsService.load()
        self.cityListViewModel = CityListViewModel(repository: repository)
        self.currentWeatherViewModel = CurrentWeatherViewModel(
            repository: repository,
            locationService: locationService
        )
    }

    // MARK: - Settings Persistence

    public func saveSettings() {
        settingsService.save(settings)
    }

    // MARK: - Factory

    public func makeCitySearchViewModel() -> CitySearchViewModel {
        CitySearchViewModel(repository: repository, cityListViewModel: cityListViewModel)
    }
}
