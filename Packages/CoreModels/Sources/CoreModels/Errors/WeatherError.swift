import Foundation

// MARK: - WeatherError

public enum WeatherError: Error, Sendable, Equatable {
    case locationDenied
    case locationUnavailable
    case networkFailure(String) // Error は Equatable 非準拠なため String メッセージをラップ
    case decodingFailure
    case cityLimitReached

    // MARK: - ユーザー向けメッセージ

    public var userMessage: String {
        switch self {
        case .locationDenied:
            "位置情報の使用が許可されていません。設定アプリから許可してください。"
        case .locationUnavailable:
            "位置情報を取得できませんでした。"
        case let .networkFailure(message):
            "通信エラー: \(message)"
        case .decodingFailure:
            "データの読み込みに失敗しました。"
        case .cityLimitReached:
            "登録できる都市は最大10件です。"
        }
    }

    // MARK: - リトライ可否

    public var isRetryable: Bool {
        switch self {
        case .locationDenied:
            false
        case .locationUnavailable:
            true
        case .networkFailure:
            true
        case .decodingFailure:
            false
        case .cityLimitReached:
            false
        }
    }
}
