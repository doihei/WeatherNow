import Foundation

// MARK: - Weather（APIレスポンス全体）

public struct Weather: Sendable, Equatable {
    public let current: CurrentWeather
    public let hourly: [HourlyForecast]
    public let daily: [DailyForecast]

    public init(current: CurrentWeather, hourly: [HourlyForecast], daily: [DailyForecast]) {
        self.current = current
        self.hourly = hourly
        self.daily = daily
    }
}
