import CoreModels
import Dependencies

private enum WeatherAPIClientKey: DependencyKey {
    static let liveValue: any WeatherAPIClientProtocol = LiveWeatherAPIClient()

    static var testValue: any WeatherAPIClientProtocol {
        UnimplementedWeatherAPIClient()
    }
}

private struct UnimplementedWeatherAPIClient: WeatherAPIClientProtocol {
    func fetchWeather(latitude _: Double, longitude _: Double) async throws -> Weather {
        preconditionFailure("weatherAPIClient を withDependencies で上書きしてください")
    }
}

public extension DependencyValues {
    var weatherAPIClient: any WeatherAPIClientProtocol {
        get { self[WeatherAPIClientKey.self] }
        set { self[WeatherAPIClientKey.self] = newValue }
    }
}
