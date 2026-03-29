import Dependencies

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

public extension DependencyValues {
    var locationService: any LocationServiceProtocol {
        get { self[LocationServiceKey.self] }
        set { self[LocationServiceKey.self] = newValue }
    }
}
