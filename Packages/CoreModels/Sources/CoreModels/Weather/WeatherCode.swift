import Foundation

// MARK: - WeatherCode（WMOコード変換）

public enum WeatherCode: Int, Sendable, Equatable, Codable {
    case clearSky = 0
    case mainlyClear = 1
    case partlyCloudy = 2
    case overcast = 3
    case fog = 45
    case rimeFog = 48
    case lightDrizzle = 51
    case moderateDrizzle = 53
    case denseDrizzle = 55
    case lightRain = 61
    case moderateRain = 63
    case heavyRain = 65
    case lightSnow = 71
    case moderateSnow = 73
    case heavySnow = 75
    case snowGrains = 77
    case lightRainShower = 80
    case moderateRainShower = 81
    case violentRainShower = 82
    case lightSnowShower = 85
    case heavySnowShower = 86
    case thunderstorm = 95
    case thunderstormWithHail = 96
    case thunderstormWithHeavyHail = 99
    case unknown = -1

    public init(wmoCode: Int) {
        self = WeatherCode(rawValue: wmoCode) ?? .unknown
    }

    /// 天気テキスト（日本語）
    public var description: String {
        switch self {
        case .clearSky:
            "快晴"
        case .mainlyClear:
            "晴れ"
        case .partlyCloudy:
            "晴れ時々曇り"
        case .overcast:
            "曇り"
        case .fog:
            "霧"
        case .rimeFog:
            "霧氷"
        case .lightDrizzle:
            "小雨（霧雨）"
        case .moderateDrizzle:
            "霧雨"
        case .denseDrizzle:
            "濃い霧雨"
        case .lightRain:
            "小雨"
        case .moderateRain:
            "雨"
        case .heavyRain:
            "大雨"
        case .lightSnow:
            "小雪"
        case .moderateSnow:
            "雪"
        case .heavySnow:
            "大雪"
        case .snowGrains:
            "みぞれ"
        case .lightRainShower:
            "にわか雨（弱）"
        case .moderateRainShower:
            "にわか雨"
        case .violentRainShower:
            "激しいにわか雨"
        case .lightSnowShower:
            "にわか雪（弱）"
        case .heavySnowShower:
            "激しいにわか雪"
        case .thunderstorm:
            "雷雨"
        case .thunderstormWithHail:
            "雷雨（ひょう）"
        case .thunderstormWithHeavyHail:
            "激しい雷雨（ひょう）"
        case .unknown:
            "不明"
        }
    }
}
