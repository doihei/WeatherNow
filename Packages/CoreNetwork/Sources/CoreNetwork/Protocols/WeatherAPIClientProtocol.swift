import CoreModels

// MARK: - WeatherAPIClientProtocol

public protocol WeatherAPIClientProtocol: Sendable {
    func fetchWeather(latitude: Double, longitude: Double) async throws -> Weather
}
