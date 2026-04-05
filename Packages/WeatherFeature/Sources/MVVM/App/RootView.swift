import CoreModels
import CoreUI
import SwiftUI

// MARK: - RootView

public struct RootView: View {
    @State private var appViewModel = AppViewModel()

    public init() {}

    public var body: some View {
        TabView(selection: Binding(
            get: { appViewModel.selectedTab },
            set: { appViewModel.selectedTab = $0 }
        )) {
            weatherTab
                .tag(AppViewModel.Tab.weather)
                .tabItem {
                    Label(L10n.tabWeather, systemImage: AppSymbol.weatherTab.rawValue)
                }

            cityTab
                .tag(AppViewModel.Tab.city)
                .tabItem {
                    Label(L10n.tabCity, systemImage: AppSymbol.cityTab.rawValue)
                }

            settingsTab
                .tag(AppViewModel.Tab.settings)
                .tabItem {
                    Label(L10n.tabSettings, systemImage: AppSymbol.settingsTab.rawValue)
                }
        }
        .preferredColorScheme(appViewModel.settings.theme.colorScheme)
        .task {
            appViewModel.loadSettings()
        }
    }

    // MARK: - Weather Tab

    private var weatherTab: some View {
        NavigationStack(path: $appViewModel.weatherPath) {
            CurrentWeatherView(
                viewModel: appViewModel.currentWeatherViewModel,
                weatherPath: $appViewModel.weatherPath,
                settings: appViewModel.settings
            )
            .navigationDestination(for: WeatherDestination.self) { destination in
                weatherDestinationView(destination)
            }
        }
    }

    @ViewBuilder
    private func weatherDestinationView(_ destination: WeatherDestination) -> some View {
        if case let .loaded(weather) = appViewModel.currentWeatherViewModel.state {
            switch destination {
            case .weeklyForecast:
                WeeklyForecastView(
                    viewModel: WeeklyForecastViewModel(weather: weather),
                    temperatureUnit: appViewModel.settings.temperatureUnit
                )
            case .hourlyChart:
                HourlyChartView(
                    hourlyForecasts: weather.hourly,
                    temperatureUnit: appViewModel.settings.temperatureUnit
                )
            }
        }
    }

    // MARK: - City Tab

    private var cityTab: some View {
        NavigationStack(path: $appViewModel.cityPath) {
            CityListView(
                viewModel: appViewModel.cityListViewModel,
                cityPath: $appViewModel.cityPath,
                settings: appViewModel.settings,
                makeCitySearchViewModel: appViewModel.makeCitySearchViewModel
            )
        }
    }

    // MARK: - Settings Tab

    private var settingsTab: some View {
        NavigationStack {
            SettingsView(appViewModel: appViewModel)
        }
    }
}
