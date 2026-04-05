import Charts
import CoreModels
import CoreUI
import SwiftUI

// MARK: - HourlyChartView

public struct HourlyChartView: View {
    let hourlyForecasts: [HourlyForecast]
    let temperatureUnit: AppSettings.TemperatureUnit

    public init(hourlyForecasts: [HourlyForecast], temperatureUnit: AppSettings.TemperatureUnit) {
        self.hourlyForecasts = hourlyForecasts
        self.temperatureUnit = temperatureUnit
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxLarge) {
                temperatureChart
                precipitationChart
            }
            .padding()
        }
        .navigationTitle(L10n.hourlyChartTitle)
    }

    // MARK: - Private Views

    private var temperatureChart: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(L10n.hourlyChartTemperature)
                .font(.headline)
            Chart(hourlyForecasts) { forecast in
                LineMark(
                    x: .value(L10n.hourlyChartTime.string(), forecast.time),
                    y: .value(L10n.hourlyChartTemperature.string(), temperatureUnit.convert(forecast.temperature))
                )
                .foregroundStyle(.orange)
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 3)) {
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .chartYAxisLabel(temperatureUnit.symbol)
            .frame(height: Size.chartDefault)
        }
    }

    private var precipitationChart: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(L10n.hourlyChartPrecipitation)
                .font(.headline)
            Chart(hourlyForecasts) { forecast in
                BarMark(
                    x: .value(L10n.hourlyChartTime.string(), forecast.time),
                    y: .value(L10n.hourlyChartPrecipitation.string(), forecast.precipitation)
                )
                .foregroundStyle(.blue)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 3)) {
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .chartYAxisLabel("mm")
            .frame(height: Size.chartDefault)
        }
    }
}
