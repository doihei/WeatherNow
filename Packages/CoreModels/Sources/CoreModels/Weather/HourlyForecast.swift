import Foundation

// MARK: - HourlyForecast（1時間分の予報）

public struct HourlyForecast: Sendable, Equatable, Identifiable {
    public let id: String
    public let time: Date
    public let temperature: Double
    public let precipitation: Double // mm
    public let code: WeatherCode

    public init(time: Date, temperature: Double, precipitation: Double, code: WeatherCode) {
        self.id = ISO8601DateFormatter().string(from: time)
        self.time = time
        self.temperature = temperature
        self.precipitation = precipitation
        self.code = code
    }
}
