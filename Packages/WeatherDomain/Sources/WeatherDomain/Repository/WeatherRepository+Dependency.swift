import CoreModels
import Dependencies

private enum WeatherRepositoryKey: DependencyKey {
    static let liveValue: any WeatherRepositoryProtocol = WeatherRepository()

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

public extension DependencyValues {
    var weatherRepository: any WeatherRepositoryProtocol {
        get { self[WeatherRepositoryKey.self] }
        set { self[WeatherRepositoryKey.self] = newValue }
    }
}
