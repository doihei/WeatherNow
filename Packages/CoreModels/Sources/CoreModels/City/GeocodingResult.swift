import Foundation

// MARK: - GeocodingResult（都市検索結果）

public struct GeocodingResult: Sendable, Equatable, Identifiable {
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

    public func toCity() -> City {
        City(id: id, name: name, country: country, latitude: latitude, longitude: longitude)
    }
}
