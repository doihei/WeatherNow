import CoreModels
import CoreNetwork
import Dependencies
import WeatherDomain

// MARK: - WeatherRepository

private enum WeatherRepositoryKey: DependencyKey {
    static let liveValue: any WeatherRepositoryProtocol = WeatherRepository(
        weatherClient: LiveWeatherAPIClient(),
        geocodingClient: LiveGeocodingAPIClient()
    )

    static var testValue: any WeatherRepositoryProtocol {
        UnimplementedWeatherRepository()
    }
}

private struct UnimplementedWeatherRepository: WeatherRepositoryProtocol {
    func fetchWeather(latitude _: Double, longitude _: Double) async throws -> Weather {
        preconditionFailure("weatherRepository を withDependencies で上書きしてください")
    }

    func searchCities(name _: String) async throws -> [GeocodingResult] {
        preconditionFailure("weatherRepository を withDependencies で上書きしてください")
    }

    func clearCache() async {
        preconditionFailure("weatherRepository を withDependencies で上書きしてください")
    }
}

extension DependencyValues {
    var weatherRepository: any WeatherRepositoryProtocol {
        get { self[WeatherRepositoryKey.self] }
        set { self[WeatherRepositoryKey.self] = newValue }
    }
}

// MARK: - LocationService

private enum LocationServiceKey: DependencyKey {
    static let liveValue: any LocationServiceProtocol = LocationService()

    static var testValue: any LocationServiceProtocol {
        UnimplementedLocationService()
    }
}

private struct UnimplementedLocationService: LocationServiceProtocol {
    func requestCurrentLocation() async throws -> (latitude: Double, longitude: Double) {
        preconditionFailure("locationService を withDependencies で上書きしてください")
    }
}

extension DependencyValues {
    var locationService: any LocationServiceProtocol {
        get { self[LocationServiceKey.self] }
        set { self[LocationServiceKey.self] = newValue }
    }
}

// MARK: - AppSettingsService

private enum AppSettingsServiceKey: DependencyKey {
    static let liveValue: any AppSettingsServiceProtocol = AppSettingsService()
    static let testValue: any AppSettingsServiceProtocol = AppSettingsService()
}

extension DependencyValues {
    var appSettingsService: any AppSettingsServiceProtocol {
        get { self[AppSettingsServiceKey.self] }
        set { self[AppSettingsServiceKey.self] = newValue }
    }
}

// MARK: - CityListService

private enum CityListServiceKey: DependencyKey {
    static let liveValue: any CityListServiceProtocol = CityListService()
    static let testValue: any CityListServiceProtocol = CityListService()
}

extension DependencyValues {
    var cityListService: any CityListServiceProtocol {
        get { self[CityListServiceKey.self] }
        set { self[CityListServiceKey.self] = newValue }
    }
}
