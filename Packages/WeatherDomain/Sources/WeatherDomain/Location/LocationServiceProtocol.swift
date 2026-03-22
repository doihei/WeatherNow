// MARK: - LocationServiceProtocol

public protocol LocationServiceProtocol: Sendable {
    func requestCurrentLocation() async throws -> (latitude: Double, longitude: Double)
}
