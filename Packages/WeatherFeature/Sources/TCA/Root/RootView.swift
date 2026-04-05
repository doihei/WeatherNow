import ComposableArchitecture
import CoreModels
import CoreUI
import SwiftUI

// MARK: - RootView (TCA)

public struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>

    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }

    public var body: some View {
        TabView(selection: Binding(
            get: { store.selectedTab },
            set: { store.send(.tabSelected($0)) }
        )) {
            weatherTab
                .tag(RootFeature.Tab.weather)
                .tabItem {
                    Label(L10n.tabWeather, systemImage: AppSymbol.weatherTab.rawValue)
                }

            cityTab
                .tag(RootFeature.Tab.city)
                .tabItem {
                    Label(L10n.tabCity, systemImage: AppSymbol.cityTab.rawValue)
                }

            settingsTab
                .tag(RootFeature.Tab.settings)
                .tabItem {
                    Label(L10n.tabSettings, systemImage: AppSymbol.settingsTab.rawValue)
                }
        }
        .preferredColorScheme(store.settings.theme.colorScheme)
        .task {
            store.send(.onAppear)
        }
    }

    // MARK: - Weather Tab

    private var weatherTab: some View {
        NavigationStack(
            path: $store.scope(state: \.weatherPath, action: \.weatherPath)
        ) {
            CurrentWeatherView(
                store: store.scope(state: \.currentWeather, action: \.currentWeather),
                settings: store.settings
            )
        } destination: { pathStore in
            switch pathStore.case {
            case let .weeklyForecast(weeklyStore):
                WeeklyForecastView(
                    store: weeklyStore,
                    temperatureUnit: store.settings.temperatureUnit
                )
            case let .hourlyChart(chartStore):
                HourlyChartView(
                    store: chartStore,
                    temperatureUnit: store.settings.temperatureUnit
                )
            }
        }
    }

    // MARK: - City Tab

    private var cityTab: some View {
        NavigationStack(
            path: $store.scope(state: \.cityPath, action: \.cityPath)
        ) {
            CityListView(
                store: store.scope(state: \.cityList, action: \.cityList),
                temperatureUnit: store.settings.temperatureUnit
            )
        } destination: { pathStore in
            switch pathStore.case {
            case let .citySearch(searchStore):
                CitySearchView(store: searchStore)
            }
        }
    }

    // MARK: - Settings Tab

    private var settingsTab: some View {
        NavigationStack {
            SettingsView(store: store)
        }
    }
}
