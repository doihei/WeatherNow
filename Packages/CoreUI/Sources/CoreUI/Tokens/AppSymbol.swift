import SFSafeSymbols

public enum AppSymbol {
    // Tab bar
    public static let weatherTab: SFSymbol = .cloudSunFill
    public static let cityTab: SFSymbol = .building2Fill
    public static let settingsTab: SFSymbol = .gearshapeFill

    // Weather detail actions
    public static let thermometer: SFSymbol = .thermometerMedium
    public static let humidity: SFSymbol = .humidity
    public static let wind: SFSymbol = .wind
    public static let weeklyForecast: SFSymbol = .calendar
    public static let hourlyChart: SFSymbol = .chartLineUptrendXyaxis
    public static let errorWarning: SFSymbol = .exclamationmarkTriangle

    // City list / search
    public static let addCity: SFSymbol = .plus
    public static let cityAdded: SFSymbol = .checkmarkCircleFill
    public static let addCityButton: SFSymbol = .plusCircle
}
