import CoreModels
import Foundation

public struct CityListService: CityListServiceProtocol, @unchecked Sendable {
    private static let citiesKey = "registeredCities"
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load() -> [City] {
        guard
            let data = defaults.data(forKey: Self.citiesKey),
            let decoded = try? JSONDecoder().decode([City].self, from: data)
        else { return [] }
        return decoded
    }

    public func save(_ cities: [City]) {
        guard let data = try? JSONEncoder().encode(cities) else { return }
        defaults.set(data, forKey: Self.citiesKey)
    }
}
