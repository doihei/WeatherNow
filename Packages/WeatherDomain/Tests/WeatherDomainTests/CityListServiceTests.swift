import CoreModels
import Foundation
import Testing
@testable import WeatherDomain

struct CityListServiceTests {
    @Test("空の UserDefaults からロードすると空配列を返す")
    func loadFromEmptyReturnsEmptyArray() throws {
        let defaults = try #require(UserDefaults(suiteName: "test_city_\(UUID().uuidString)"))
        let service = CityListService(defaults: defaults)
        #expect(service.load() == [])
    }

    @Test("save した都市リストを load で取得できる", arguments: [
        [City(id: 1, name: "東京", country: "日本", latitude: 35.68, longitude: 139.69)],
        [
            City(id: 1, name: "東京", country: "日本", latitude: 35.68, longitude: 139.69),
            City(id: 2, name: "大阪", country: "日本", latitude: 34.69, longitude: 135.50),
        ],
    ])
    func saveLoadRoundTrip(cities: [City]) throws {
        let defaults = try #require(UserDefaults(suiteName: "test_city_\(UUID().uuidString)"))
        let service = CityListService(defaults: defaults)
        service.save(cities)
        #expect(service.load() == cities)
    }

    @Test("空配列を save すると load で空配列が返る")
    func saveEmptyArrayReturnsEmpty() throws {
        let defaults = try #require(UserDefaults(suiteName: "test_city_\(UUID().uuidString)"))
        let service = CityListService(defaults: defaults)
        service.save([City(id: 1, name: "東京", country: "日本", latitude: 35.68, longitude: 139.69)])
        service.save([])
        #expect(service.load() == [])
    }

    @Test("異なる UserDefaults インスタンス間でデータが分離される")
    func isolatedDefaults() throws {
        let defaults1 = try #require(UserDefaults(suiteName: "test_city_a_\(UUID().uuidString)"))
        let defaults2 = try #require(UserDefaults(suiteName: "test_city_b_\(UUID().uuidString)"))
        let service1 = CityListService(defaults: defaults1)
        let service2 = CityListService(defaults: defaults2)

        service1.save([City(id: 1, name: "東京", country: "日本", latitude: 35.68, longitude: 139.69)])

        #expect(service2.load() == [])
    }
}
