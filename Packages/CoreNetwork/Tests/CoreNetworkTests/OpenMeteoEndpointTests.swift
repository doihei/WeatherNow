import Foundation
import Testing
@testable import CoreNetwork

struct OpenMeteoEndpointTests {
    // MARK: - forecast

    @Test("forecast URL のホストが正しい")
    func forecastHost() throws {
        let url = try OpenMeteoEndpoint.forecast(latitude: 35.68, longitude: 139.69).url
        #expect(url.host == "api.open-meteo.com")
    }

    @Test("forecast URL のパスが正しい")
    func forecastPath() throws {
        let url = try OpenMeteoEndpoint.forecast(latitude: 0, longitude: 0).url
        #expect(url.path == "/v1/forecast")
    }

    @Test("forecast クエリに latitude/longitude が含まれる")
    func forecastCoordinates() throws {
        let url = try OpenMeteoEndpoint.forecast(latitude: 35.68, longitude: 139.69).url
        let items = queryDict(from: url)
        #expect(items["latitude"] == "35.68")
        #expect(items["longitude"] == "139.69")
    }

    @Test("forecast クエリに current/hourly/daily/timezone/forecast_days が含まれる")
    func forecastRequiredParams() throws {
        let url = try OpenMeteoEndpoint.forecast(latitude: 0, longitude: 0).url
        let items = queryDict(from: url)
        #expect(items["current"]?.contains("temperature_2m") == true)
        #expect(items["hourly"]?.contains("precipitation") == true)
        #expect(items["daily"]?.contains("temperature_2m_max") == true)
        #expect(items["timezone"] == "auto")
        #expect(items["forecast_days"] == "7")
    }

    @Test("forecast の current に必須フィールドがすべて含まれる")
    func forecastCurrentFields() throws {
        let url = try OpenMeteoEndpoint.forecast(latitude: 0, longitude: 0).url
        let currentValue = queryDict(from: url)["current"] ?? ""
        let requiredFields = [
            "temperature_2m", "apparent_temperature",
            "relativehumidity_2m", "weathercode", "windspeed_10m",
        ]
        for field in requiredFields {
            #expect(currentValue.contains(field), "\(field) が current パラメータに含まれない")
        }
    }

    // MARK: - geocoding

    @Test("geocoding URL のホストが正しい")
    func geocodingHost() throws {
        let url = try OpenMeteoEndpoint.geocoding(name: "Tokyo", count: 10).url
        #expect(url.host == "geocoding-api.open-meteo.com")
    }

    @Test("geocoding URL のパスが正しい")
    func geocodingPath() throws {
        let url = try OpenMeteoEndpoint.geocoding(name: "Tokyo", count: 10).url
        #expect(url.path == "/v1/search")
    }

    @Test("geocoding クエリに name/count/language が含まれる")
    func geocodingQueryParams() throws {
        let url = try OpenMeteoEndpoint.geocoding(name: "東京", count: 5).url
        let items = queryDict(from: url)
        #expect(items["name"] == "東京")
        #expect(items["count"] == "5")
        #expect(items["language"] == "ja")
    }

    // MARK: - Helper

    private func queryDict(from url: URL) -> [String: String] {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = components?.queryItems ?? []
        return Dictionary(uniqueKeysWithValues: items.compactMap { item in
            guard let value = item.value else { return nil }
            return (item.name, value)
        })
    }
}
