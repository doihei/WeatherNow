import CoreModels

// MARK: - WeatherRepositoryProtocol

public protocol WeatherRepositoryProtocol: Sendable {
    func fetchWeather(latitude: Double, longitude: Double) async throws -> Weather
    func searchCities(name: String) async throws -> [GeocodingResult]
    func clearCache()
}
