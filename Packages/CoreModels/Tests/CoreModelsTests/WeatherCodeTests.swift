import Testing
@testable import CoreModels

struct WeatherCodeTests {
    @Test("init(wmoCode:) で既知のWMOコードを正しく変換する", arguments: zip(
        [0, 1, 2, 3, 45, 48, 61, 65, 71, 75, 95, 99],
        [
            WeatherCode.clearSky, .mainlyClear, .partlyCloudy, .overcast,
            .fog, .rimeFog, .lightRain, .heavyRain, .lightSnow, .heavySnow,
            .thunderstorm, .thunderstormWithHeavyHail,
        ]
    ))
    func knownWMOCode(wmoCode: Int, expected: WeatherCode) {
        #expect(WeatherCode(wmoCode: wmoCode) == expected)
    }

    @Test("init(wmoCode:) で未知のコードは .unknown を返す")
    func unknownWMOCode() {
        #expect(WeatherCode(wmoCode: 999) == .unknown)
        #expect(WeatherCode(wmoCode: 100) == .unknown)
        #expect(WeatherCode(wmoCode: -99) == .unknown)
    }

    @Test("rawValue で直接初期化できる")
    func rawValueInit() {
        #expect(WeatherCode(rawValue: 0) == .clearSky)
        #expect(WeatherCode(rawValue: 999) == nil)
    }

    @Test("description が正しい日本語テキストを返す", arguments: zip(
        [WeatherCode.clearSky, .mainlyClear, .overcast, .heavyRain, .thunderstorm, .unknown],
        ["快晴", "晴れ", "曇り", "大雨", "雷雨", "不明"]
    ))
    func description(code: WeatherCode, expected: String) {
        #expect(code.description == expected)
    }

    @Test("全ケースに description が定義されている")
    func allCasesHaveDescription() {
        let allCases: [WeatherCode] = [
            .clearSky, .mainlyClear, .partlyCloudy, .overcast,
            .fog, .rimeFog, .lightDrizzle, .moderateDrizzle, .denseDrizzle,
            .lightRain, .moderateRain, .heavyRain,
            .lightSnow, .moderateSnow, .heavySnow, .snowGrains,
            .lightRainShower, .moderateRainShower, .violentRainShower,
            .lightSnowShower, .heavySnowShower,
            .thunderstorm, .thunderstormWithHail, .thunderstormWithHeavyHail,
            .unknown,
        ]
        for code in allCases {
            #expect(!code.description.isEmpty, "description が空: \(code)")
        }
    }
}
