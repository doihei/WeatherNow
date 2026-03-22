import CoreModels
import CoreNetwork
import Foundation

// MARK: - WeatherRepository

public actor WeatherRepository: WeatherRepositoryProtocol {
    private let weatherClient: any WeatherAPIClientProtocol
    private let geocodingClient: any GeocodingAPIClientProtocol

    // キー: "lat,lon"（小数点2桁で丸め）、値: (天気データ, キャッシュ日時)
    private var cache: [String: (weather: Weather, cachedAt: Date)] = [:]
    private let cacheDuration: TimeInterval = 600 // 10分

    public init(
        weatherClient: any WeatherAPIClientProtocol,
        geocodingClient: any GeocodingAPIClientProtocol
    ) {
        self.weatherClient = weatherClient
        self.geocodingClient = geocodingClient
    }

    // MARK: - WeatherRepositoryProtocol

    public func fetchWeather(latitude: Double, longitude: Double) async throws -> Weather {
        let key = cacheKey(latitude: latitude, longitude: longitude)

        if let cached = cache[key], Date().timeIntervalSince(cached.cachedAt) < cacheDuration {
            return cached.weather
        }

        do {
            let weather = try await weatherClient.fetchWeather(latitude: latitude, longitude: longitude)
            cache[key] = (weather: weather, cachedAt: Date())
            return weather
        } catch let error as WeatherError {
            throw error
        } catch {
            throw WeatherError.networkFailure(error.localizedDescription)
        }
    }

    public func searchCities(name: String) async throws -> [GeocodingResult] {
        do {
            return try await geocodingClient.searchCities(name: name, count: 10)
        } catch let error as WeatherError {
            throw error
        } catch {
            throw WeatherError.networkFailure(error.localizedDescription)
        }
    }

    public func clearCache() {
        cache.removeAll()
    }

    // MARK: - Private

    private func cacheKey(latitude: Double, longitude: Double) -> String {
        // 小数点2桁（約1km精度）でキーを正規化
        let lat = (latitude * 100).rounded() / 100
        let lon = (longitude * 100).rounded() / 100
        return "\(lat),\(lon)"
    }
}
