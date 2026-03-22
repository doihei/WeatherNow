import CoreModels
import SFSafeSymbols

// MARK: - WeatherCode + SFSymbol

public extension WeatherCode {
    var symbol: SFSymbol {
        switch self {
        case .clearSky:
            .sunMaxFill
        case .mainlyClear:
            .sunMax
        case .partlyCloudy:
            .cloudSunFill
        case .overcast:
            .cloudFill
        case .fog, .rimeFog:
            .cloudFogFill
        case .lightDrizzle, .moderateDrizzle, .denseDrizzle:
            .cloudDrizzleFill
        case .lightRain, .moderateRain, .heavyRain:
            .cloudRainFill
        case .lightSnow, .moderateSnow, .heavySnow, .snowGrains:
            .cloudSnowFill
        case .lightRainShower, .moderateRainShower, .violentRainShower:
            .cloudHeavyrainFill
        case .lightSnowShower, .heavySnowShower:
            .cloudSnowFill
        case .thunderstorm:
            .cloudBoltFill
        case .thunderstormWithHail, .thunderstormWithHeavyHail:
            .cloudBoltRainFill
        case .unknown:
            .questionmarkCircle
        }
    }
}
