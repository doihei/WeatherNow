import Foundation

// MARK: - CurrentWeather（現在の天気）

public struct CurrentWeather: Sendable, Equatable {
    public let temperature: Double // temperature_2m
    public let feelsLike: Double // apparent_temperature
    public let humidity: Int // relativehumidity_2m
    public let windSpeed: Double // windspeed_10m (km/h)
    public let code: WeatherCode

    public init(temperature: Double, feelsLike: Double, humidity: Int, windSpeed: Double, code: WeatherCode) {
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.code = code
    }
}
