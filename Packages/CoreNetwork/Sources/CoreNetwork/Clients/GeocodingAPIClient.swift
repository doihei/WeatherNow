import CoreModels
import Foundation

// MARK: - LiveGeocodingAPIClient

public struct LiveGeocodingAPIClient: GeocodingAPIClientProtocol {
    private let apiClient = APIClient()

    public init() {}

    public func searchCities(name: String, count: Int = 10) async throws -> [GeocodingResult] {
        do {
            let url = try OpenMeteoEndpoint.geocoding(name: name, count: count).url
            let response: GeocodingResponse = try await apiClient.get(url: url)
            return response.toResults()
        } catch let error as WeatherError {
            throw error
        } catch let urlError as URLError {
            throw WeatherError.networkFailure(urlError.localizedDescription)
        } catch {
            throw WeatherError.networkFailure(error.localizedDescription)
        }
    }
}

// MARK: - TestGeocodingAPIClient

public struct TestGeocodingAPIClient: GeocodingAPIClientProtocol {
    public var searchCitiesHandler: @Sendable (String, Int) async throws -> [GeocodingResult]

    public init(
        searchCitiesHandler: @Sendable @escaping (String, Int) async throws -> [GeocodingResult] = { _, _ in
            [
                GeocodingResult(id: 1_850_147, name: "東京", country: "日本", latitude: 35.6762, longitude: 139.6503),
                GeocodingResult(id: 1_853_909, name: "大阪", country: "日本", latitude: 34.6939, longitude: 135.5022),
            ]
        }
    ) {
        self.searchCitiesHandler = searchCitiesHandler
    }

    public func searchCities(name: String, count: Int) async throws -> [GeocodingResult] {
        try await searchCitiesHandler(name, count)
    }
}
