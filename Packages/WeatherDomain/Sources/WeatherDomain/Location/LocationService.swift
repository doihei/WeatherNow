import CoreLocation
import CoreModels

// MARK: - LocationService

public actor LocationService: LocationServiceProtocol {
    public init() {}

    // MARK: - LocationServiceProtocol

    /// 現在地の座標を取得する。
    /// iOS 17+ の `CLLocationUpdate.liveUpdates()` を使用し、delegate 不要で実装。
    public func requestCurrentLocation() async throws -> (latitude: Double, longitude: Double) {
        for try await update in CLLocationUpdate.liveUpdates() {
            if update.authorizationDenied {
                throw WeatherError.locationDenied
            }

            if let location = update.location {
                return (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
        }

        // AsyncSequence が終了した場合（通常は起きない）
        throw WeatherError.locationUnavailable
    }
}
