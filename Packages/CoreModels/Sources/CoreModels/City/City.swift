import Foundation

// MARK: - City（登録都市）

public struct City: Sendable, Equatable, Identifiable, Hashable, Codable {
    public let id: Int
    public let name: String
    public let country: String
    public let latitude: Double
    public let longitude: Double

    public init(id: Int, name: String, country: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
}
