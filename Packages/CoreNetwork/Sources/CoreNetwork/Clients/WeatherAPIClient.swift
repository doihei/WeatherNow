import CoreModels
import Foundation

// MARK: - LiveWeatherAPIClient

public struct LiveWeatherAPIClient: WeatherAPIClientProtocol {
    private let apiClient = APIClient()

    public init() {}

    public func fetchWeather(latitude: Double, longitude: Double) async throws -> Weather {
        do {
            let url = try OpenMeteoEndpoint.forecast(latitude: latitude, longitude: longitude).url
            let response: ForecastResponse = try await apiClient.get(url: url)
            return response.toWeather()
        } catch let error as WeatherError {
            throw error
        } catch let urlError as URLError {
            throw WeatherError.networkFailure(urlError.localizedDescription)
        } catch {
            throw WeatherError.networkFailure(error.localizedDescription)
        }
    }
}

// MARK: - TestWeatherAPIClient

public struct TestWeatherAPIClient: WeatherAPIClientProtocol {
    public var fetchWeatherHandler: @Sendable (Double, Double) async throws -> Weather

    public init(
        fetchWeatherHandler: @Sendable @escaping (Double, Double) async throws -> Weather = { _, _ in
            Weather(
                current: CurrentWeather(
                    temperature: 22.0,
                    feelsLike: 20.0,
                    humidity: 60,
                    windSpeed: 12.0,
                    code: .clearSky
                ),
                hourly: [],
                daily: []
            )
        }
    ) {
        self.fetchWeatherHandler = fetchWeatherHandler
    }

    public func fetchWeather(latitude: Double, longitude: Double) async throws -> Weather {
        try await fetchWeatherHandler(latitude, longitude)
    }
}
