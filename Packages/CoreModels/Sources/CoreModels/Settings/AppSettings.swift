import Foundation

// MARK: - AppSettings

public struct AppSettings: Sendable, Equatable {
    public var temperatureUnit: TemperatureUnit
    public var windUnit: WindUnit
    public var theme: Theme

    public static let `default` = AppSettings(
        temperatureUnit: .celsius,
        windUnit: .kmh,
        theme: .system
    )

    public init(temperatureUnit: TemperatureUnit, windUnit: WindUnit, theme: Theme) {
        self.temperatureUnit = temperatureUnit
        self.windUnit = windUnit
        self.theme = theme
    }
}

// MARK: - AppSettings.TemperatureUnit

public extension AppSettings {
    enum TemperatureUnit: String, Sendable, CaseIterable, Codable {
        case celsius
        case fahrenheit

        public var symbol: String {
            switch self {
            case .celsius: "℃"
            case .fahrenheit: "℉"
            }
        }

        public func convert(_ celsius: Double) -> Double {
            switch self {
            case .celsius: celsius
            case .fahrenheit: celsius * 9 / 5 + 32
            }
        }
    }
}

// MARK: - AppSettings.WindUnit

public extension AppSettings {
    enum WindUnit: String, Sendable, CaseIterable, Codable {
        case kmh
        case mph

        public var symbol: String {
            switch self {
            case .kmh: "km/h"
            case .mph: "mph"
            }
        }

        public func convert(_ kmh: Double) -> Double {
            switch self {
            case .kmh: kmh
            case .mph: kmh * 0.621371
            }
        }
    }
}

// MARK: - AppSettings.Theme

public extension AppSettings {
    enum Theme: String, Sendable, CaseIterable, Codable {
        case system
        case light
        case dark

        public var displayName: String {
            switch self {
            case .system: "システム"
            case .light: "ライト"
            case .dark: "ダーク"
            }
        }
    }
}

// MARK: - UserDefaults永続化

public extension AppSettings {
    private enum Keys {
        static let temperatureUnit = "temperatureUnit"
        static let windUnit = "windUnit"
        static let theme = "theme"
    }

    static func load(from defaults: UserDefaults = .standard) -> AppSettings {
        let tempUnit = defaults.string(forKey: Keys.temperatureUnit)
            .flatMap(TemperatureUnit.init(rawValue:)) ?? .celsius
        let windUnit = defaults.string(forKey: Keys.windUnit)
            .flatMap(WindUnit.init(rawValue:)) ?? .kmh
        let theme = defaults.string(forKey: Keys.theme)
            .flatMap(Theme.init(rawValue:)) ?? .system
        return AppSettings(temperatureUnit: tempUnit, windUnit: windUnit, theme: theme)
    }

    func save(to defaults: UserDefaults = .standard) {
        defaults.set(temperatureUnit.rawValue, forKey: Keys.temperatureUnit)
        defaults.set(windUnit.rawValue, forKey: Keys.windUnit)
        defaults.set(theme.rawValue, forKey: Keys.theme)
    }
}
