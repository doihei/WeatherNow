import CoreModels
import Foundation

// MARK: - GeocodingResponse（都市検索APIレスポンス）

struct GeocodingResponse: Decodable {
    let results: [ResultItem]?

    struct ResultItem: Decodable {
        let id: Int
        let name: String
        let country: String?
        let latitude: Double
        let longitude: Double
    }
}

// MARK: - GeocodingResponse → [GeocodingResult] 変換

extension GeocodingResponse {
    func toResults() -> [GeocodingResult] {
        (results ?? []).map { item in
            GeocodingResult(
                id: item.id,
                name: item.name,
                country: item.country ?? "",
                latitude: item.latitude,
                longitude: item.longitude
            )
        }
    }
}
