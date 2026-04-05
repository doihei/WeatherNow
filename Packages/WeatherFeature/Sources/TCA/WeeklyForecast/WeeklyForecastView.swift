import ComposableArchitecture
import CoreModels
import CoreUI
import SwiftUI

// MARK: - WeeklyForecastView (TCA)

public struct WeeklyForecastView: View {
    let store: StoreOf<WeeklyForecastFeature>
    let temperatureUnit: AppSettings.TemperatureUnit

    public init(store: StoreOf<WeeklyForecastFeature>, temperatureUnit: AppSettings.TemperatureUnit) {
        self.store = store
        self.temperatureUnit = temperatureUnit
    }

    public var body: some View {
        List(store.dailyForecasts) { forecast in
            DailyForecastRow(forecast: forecast, temperatureUnit: temperatureUnit)
        }
        .navigationTitle(L10n.weeklyForecastTitle)
        .onAppear { store.send(.onAppear) }
    }
}

// MARK: - DailyForecastRow

private struct DailyForecastRow: View {
    let forecast: DailyForecast
    let temperatureUnit: AppSettings.TemperatureUnit

    var body: some View {
        HStack(spacing: Spacing.large) {
            Text(forecast.date, format: .dateTime.month().day().weekday(.abbreviated))
                .frame(width: Size.labelColumn, alignment: .leading)
                .font(.subheadline)

            WeatherIconView(code: forecast.code, size: Size.iconSM)

            Text(forecast.code.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            TemperatureText(celsius: forecast.maxTemp, unit: temperatureUnit)
                .foregroundStyle(.red)
            Text("/")
                .foregroundStyle(.secondary)
            TemperatureText(celsius: forecast.minTemp, unit: temperatureUnit)
                .foregroundStyle(.blue)

            VStack(alignment: .trailing, spacing: Spacing.xxSmall) {
                Text("\(forecast.precipitationProb)%")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                ProgressView(value: Double(forecast.precipitationProb), total: 100)
                    .frame(width: 40)
                    .tint(.blue)
            }
        }
        .padding(.vertical, Spacing.xSmall)
    }
}
