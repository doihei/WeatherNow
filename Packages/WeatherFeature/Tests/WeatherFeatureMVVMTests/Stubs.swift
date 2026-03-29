import CoreModels
import Foundation
import WeatherDomain

// MARK: - StubWeatherRepository

struct StubWeatherRepository: WeatherRepositoryProtocol {
    var weatherStub: Weather = .stub()
    var searchStub: [GeocodingResult] = []

    func fetchWeather(latitude _: Double, longitude _: Double) async throws -> Weather {
        weatherStub
    }

    func searchCities(name _: String) async throws -> [GeocodingResult] {
        searchStub
    }

    func clearCache() async {}
}

// MARK: - StubLocationService

struct StubLocationService: LocationServiceProtocol {
    var location: (latitude: Double, longitude: Double) = (35.68, 139.69)

    func requestCurrentLocation() async throws -> (latitude: Double, longitude: Double) {
        location
    }
}

// MARK: - Stub Factories

extension Weather {
    static func stub(
        temperature: Double = 20.0,
        daily: [DailyForecast] = []
    ) -> Weather {
        Weather(
            current: CurrentWeather(
                temperature: temperature,
                feelsLike: 18.0,
                humidity: 55,
                windSpeed: 10.0,
                code: .clearSky
            ),
            hourly: [],
            daily: daily
        )
    }
}

extension GeocodingResult {
    static func stub(
        id: Int = 1,
        name: String = "東京",
        country: String = "日本",
        latitude: Double = 35.68,
        longitude: Double = 139.69
    ) -> GeocodingResult {
        GeocodingResult(id: id, name: name, country: country, latitude: latitude, longitude: longitude)
    }
}

extension DailyForecast {
    static func stub(date: Date = Date()) -> DailyForecast {
        DailyForecast(date: date, maxTemp: 25.0, minTemp: 15.0, precipitationProb: 10, code: .clearSky)
    }
}
