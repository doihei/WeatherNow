import CoreModels
import Foundation
import Testing
@testable import CoreNetwork

struct GeocodingResponseTests {
    @Test("results を正しく GeocodingResult の配列に変換する")
    func decodeResults() throws {
        let json = Data("""
        {
            "results": [
                {"id": 1850147, "name": "東京", "country": "日本", "latitude": 35.6762, "longitude": 139.6503},
                {"id": 1853909, "name": "大阪", "country": "日本", "latitude": 34.6939, "longitude": 135.5022}
            ]
        }
        """.utf8)

        let response = try JSONDecoder().decode(GeocodingResponse.self, from: json)
        let results = response.toResults()

        #expect(results.count == 2)
        #expect(results[0].id == 1_850_147)
        #expect(results[0].name == "東京")
        #expect(results[0].country == "日本")
        #expect(results[0].latitude == 35.6762)
        #expect(results[0].longitude == 139.6503)
        #expect(results[1].name == "大阪")
    }

    @Test("results が null のとき空配列を返す")
    func nullResultsReturnsEmpty() throws {
        let json = Data("{}".utf8)
        let response = try JSONDecoder().decode(GeocodingResponse.self, from: json)
        #expect(response.toResults().isEmpty)
    }

    @Test("results が空配列のとき空配列を返す")
    func emptyResultsArray() throws {
        let json = Data(#"{"results": []}"#.utf8)
        let response = try JSONDecoder().decode(GeocodingResponse.self, from: json)
        #expect(response.toResults().isEmpty)
    }

    @Test("country が null のとき空文字を返す")
    func nullCountryFallsBackToEmptyString() throws {
        let json = Data("""
        {
            "results": [
                {"id": 1, "name": "SomeCity", "latitude": 0.0, "longitude": 0.0}
            ]
        }
        """.utf8)

        let response = try JSONDecoder().decode(GeocodingResponse.self, from: json)
        let results = response.toResults()

        #expect(results.count == 1)
        #expect(results[0].country == String())
    }
}
