import CoreModels

// MARK: - GeocodingAPIClientProtocol

public protocol GeocodingAPIClientProtocol: Sendable {
    func searchCities(name: String, count: Int) async throws -> [GeocodingResult]
}
