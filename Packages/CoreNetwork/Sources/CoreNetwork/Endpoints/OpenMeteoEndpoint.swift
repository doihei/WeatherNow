import Foundation

// MARK: - OpenMeteoEndpoint

enum OpenMeteoEndpoint {
    case forecast(latitude: Double, longitude: Double)
    case geocoding(name: String, count: Int)

    var url: URL {
        get throws {
            var components = URLComponents(string: baseURL)!
            components.queryItems = queryItems
            guard let url = components.url else {
                throw URLError(.badURL)
            }
            return url
        }
    }

    // MARK: Private

    private var baseURL: String {
        switch self {
        case .forecast:
            "https://api.open-meteo.com/v1/forecast"
        case .geocoding:
            "https://geocoding-api.open-meteo.com/v1/search"
        }
    }

    private var queryItems: [URLQueryItem] {
        switch self {
        case let .forecast(latitude, longitude):
            [
                .init(name: "latitude", value: String(latitude)),
                .init(name: "longitude", value: String(longitude)),
                .init(
                    name: "current",
                    value: "temperature_2m,apparent_temperature,relativehumidity_2m,weathercode,windspeed_10m"
                ),
                .init(name: "hourly", value: "temperature_2m,precipitation,weathercode"),
                .init(
                    name: "daily",
                    value: "temperature_2m_max,temperature_2m_min,precipitation_probability_max,weathercode"
                ),
                .init(name: "timezone", value: "auto"),
                .init(name: "forecast_days", value: "7"),
            ]
        case let .geocoding(name, count):
            [
                .init(name: "name", value: name),
                .init(name: "count", value: String(count)),
                .init(name: "language", value: "ja"),
            ]
        }
    }
}
