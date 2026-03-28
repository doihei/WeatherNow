import CoreModels

public protocol CityListServiceProtocol: Sendable {
    func load() -> [City]
    func save(_ cities: [City])
}
