import Dependencies
import Foundation

private enum CityListServiceKey: DependencyKey {
    static let liveValue: any CityListServiceProtocol = CityListService()

    static var testValue: any CityListServiceProtocol {
        CityListService(defaults: UserDefaults(suiteName: "test_\(UUID().uuidString)")!)
    }
}

public extension DependencyValues {
    var cityListService: any CityListServiceProtocol {
        get { self[CityListServiceKey.self] }
        set { self[CityListServiceKey.self] = newValue }
    }
}
