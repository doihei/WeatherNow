import CoreModels
import CoreUI
import SwiftUI

// MARK: - CurrentWeatherView

public struct CurrentWeatherView: View {
    @State var viewModel: CurrentWeatherViewModel
    @Binding var weatherPath: NavigationPath
    let settings: AppSettings

    public init(
        viewModel: CurrentWeatherViewModel,
        weatherPath: Binding<NavigationPath>,
        settings: AppSettings
    ) {
        self.viewModel = viewModel
        self._weatherPath = weatherPath
        self.settings = settings
    }

    public var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear
                    .onAppear { viewModel.load() }

            case .loading:
                VStack(spacing: Spacing.xLarge) {
                    ProgressView()
                    Text(L10n.currentWeatherLoading)
                        .foregroundStyle(.secondary)
                }

            case let .loaded(weather):
                loadedView(weather: weather)

            case let .error(error):
                errorView(error: error)
            }
        }
        .navigationTitle(
            viewModel.cityName.isEmpty ? L10n.currentWeatherLoading.string() : viewModel.cityName
        )
        .refreshable {
            viewModel.refresh()
        }
    }

    // MARK: - Loaded View

    private func loadedView(weather: Weather) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxLarge) {
                currentWeatherSection(weather.current)
                hourlySection(weather.hourly)
                navigationButtons(weather: weather)
            }
            .padding()
        }
    }

    // MARK: - Current Weather Section

    private func currentWeatherSection(_ current: CurrentWeather) -> some View {
        VStack(alignment: .center, spacing: Spacing.large) {
            WeatherIconView(code: current.code, size: Size.iconLG)
            Text(current.code.description)
                .font(.title3)
                .foregroundStyle(.secondary)
            TemperatureText(celsius: current.temperature, unit: settings.temperatureUnit)
                .font(.system(size: Size.fontDisplay, weight: .thin))
            HStack(spacing: Spacing.xxLarge) {
                let feelsLike = settings.temperatureUnit.convert(current.feelsLike)
                let wind = settings.windUnit.convert(current.windSpeed)
                let feelsLikeStr = feelsLike.formatted(.number.precision(.fractionLength(0)))
                let windStr = wind.formatted(.number.precision(.fractionLength(1)))
                Label(
                    "\(L10n.currentWeatherFeelsLikePrefix.string()) \(feelsLikeStr)\(settings.temperatureUnit.symbol)",
                    systemImage: AppSymbol.thermometer.rawValue
                )
                Label("\(current.humidity)%", systemImage: AppSymbol.humidity.rawValue)
                Label(
                    "\(windStr) \(settings.windUnit.symbol)",
                    systemImage: AppSymbol.wind.rawValue
                )
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Hourly Section

    private func hourlySection(_ hourly: [HourlyForecast]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(L10n.currentWeatherTodayForecast)
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xLarge) {
                    ForEach(hourlyItems(hourly)) { forecast in
                        HourlyItemView(forecast: forecast, temperatureUnit: settings.temperatureUnit)
                    }
                }
                .padding(.horizontal, Spacing.xSmall)
            }
        }
    }

    private func hourlyItems(_ hourly: [HourlyForecast]) -> [HourlyForecast] {
        stride(from: 0, to: min(hourly.count, 24), by: 3).map { hourly[$0] }
    }

    // MARK: - Navigation Buttons

    private func navigationButtons(weather _: Weather) -> some View {
        HStack(spacing: Spacing.xLarge) {
            Button {
                weatherPath.append(WeatherDestination.weeklyForecast)
            } label: {
                Label(L10n.currentWeatherWeeklyForecastButton, systemImage: AppSymbol.weeklyForecast.rawValue)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.blue)

            Button {
                weatherPath.append(WeatherDestination.hourlyChart)
            } label: {
                Label(L10n.currentWeatherHourlyChartButton, systemImage: AppSymbol.hourlyChart.rawValue)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
    }

    // MARK: - Error View

    private func errorView(error: WeatherError) -> some View {
        VStack(spacing: Spacing.xLarge) {
            Image(systemName: AppSymbol.errorWarning.rawValue)
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(error.userMessage)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            if error.isRetryable {
                Button(L10n.currentWeatherRetry) { viewModel.load() }
                    .buttonStyle(.bordered)
            } else {
                #if os(iOS)
                    Button(L10n.currentWeatherOpenSettings) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.bordered)
                #endif
            }
        }
        .padding()
    }
}

// MARK: - HourlyItemView

private struct HourlyItemView: View {
    let forecast: HourlyForecast
    let temperatureUnit: AppSettings.TemperatureUnit

    var body: some View {
        VStack(spacing: Spacing.small) {
            Text(forecast.time, format: .dateTime.hour())
                .font(.caption2)
                .foregroundStyle(.secondary)
            WeatherIconView(code: forecast.code, size: Size.iconXS)
            TemperatureText(celsius: forecast.temperature, unit: temperatureUnit)
                .font(.caption)
        }
        .frame(width: Size.touchTarget)
    }
}
