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
            if #available(iOS 18, macOS 15, *) {
                if update.authorizationDenied {
                    throw WeatherError.locationDenied
                }
            }

            if let location = update.location {
                return (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
        }

        // シーケンス終了 = パーミッション拒否（iOS 17）または取得不能
        let status = CLLocationManager().authorizationStatus
        if status == .denied || status == .restricted {
            throw WeatherError.locationDenied
        }
        throw WeatherError.locationUnavailable
    }
}
