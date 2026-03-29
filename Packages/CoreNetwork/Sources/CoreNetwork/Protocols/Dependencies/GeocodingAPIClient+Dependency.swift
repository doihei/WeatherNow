import CoreModels
import Dependencies

private enum GeocodingAPIClientKey: DependencyKey {
    static let liveValue: any GeocodingAPIClientProtocol = LiveGeocodingAPIClient()

    static var testValue: any GeocodingAPIClientProtocol {
        UnimplementedGeocodingAPIClient()
    }
}

private struct UnimplementedGeocodingAPIClient: GeocodingAPIClientProtocol {
    func searchCities(name _: String, count _: Int) async throws -> [GeocodingResult] {
        preconditionFailure("geocodingAPIClient を withDependencies で上書きしてください")
    }
}

public extension DependencyValues {
    var geocodingAPIClient: any GeocodingAPIClientProtocol {
        get { self[GeocodingAPIClientKey.self] }
        set { self[GeocodingAPIClientKey.self] = newValue }
    }
}
