import Foundation

// MARK: - DailyForecast（1日分の予報）

public struct DailyForecast: Sendable, Equatable, Identifiable {
    public let id: String
    public let date: Date
    public let maxTemp: Double
    public let minTemp: Double
    public let precipitationProb: Int // %
    public let code: WeatherCode

    public init(date: Date, maxTemp: Double, minTemp: Double, precipitationProb: Int, code: WeatherCode) {
        self.id = ISO8601DateFormatter().string(from: date)
        self.date = date
        self.maxTemp = maxTemp
        self.minTemp = minTemp
        self.precipitationProb = precipitationProb
        self.code = code
    }
}
