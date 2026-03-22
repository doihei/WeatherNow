import Testing
@testable import CoreModels

struct WeatherErrorTests {
    @Test("isRetryable が正しい値を返す", arguments: zip(
        [
            WeatherError.locationDenied,
            .locationUnavailable,
            .networkFailure("timeout"),
            .decodingFailure,
            .cityLimitReached,
        ],
        [false, true, true, false, false]
    ))
    func isRetryable(error: WeatherError, expected: Bool) {
        #expect(error.isRetryable == expected)
    }

    @Test("userMessage がすべてのケースで空でない")
    func userMessageNotEmpty() {
        let errors: [WeatherError] = [
            .locationDenied,
            .locationUnavailable,
            .networkFailure("some detail"),
            .decodingFailure,
            .cityLimitReached,
        ]
        for error in errors {
            #expect(!error.userMessage.isEmpty, "userMessage が空: \(error)")
        }
    }

    @Test("networkFailure のメッセージに詳細が含まれる")
    func networkFailureIncludesDetail() {
        let detail = "Connection timed out"
        let error = WeatherError.networkFailure(detail)
        #expect(error.userMessage.contains(detail))
    }

    @Test("Equatable: 同じ case は等しい")
    func equalitySameCase() {
        #expect(WeatherError.locationDenied == .locationDenied)
        #expect(WeatherError.decodingFailure == .decodingFailure)
        #expect(WeatherError.networkFailure("a") == .networkFailure("a"))
    }

    @Test("Equatable: 異なる case は等しくない")
    func equalityDifferentCase() {
        #expect(WeatherError.locationDenied != .locationUnavailable)
        #expect(WeatherError.networkFailure("a") != .networkFailure("b"))
        #expect(WeatherError.networkFailure("x") != .decodingFailure)
    }
}
