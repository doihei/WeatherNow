import CoreModels
import Observation

// MARK: - WeeklyForecastViewModel

@MainActor
@Observable
public final class WeeklyForecastViewModel {
    // MARK: - State

    public let dailyForecasts: [DailyForecast]

    // MARK: - Init

    public init(weather: Weather) {
        self.dailyForecasts = weather.daily
    }
}
