import ComposableArchitecture
import CoreModels
import Testing
@testable import WeatherFeatureTCA

enum WeeklyForecastFeatureTests {
    @MainActor
    struct InitTests {
        @Test("init(weather:) で dailyForecasts が Weather.daily に一致する")
        func initSetsDailyForecasts() {
            let forecasts = [DailyForecast.stub(), DailyForecast.stub()]
            let weather = Weather.stub(daily: forecasts)
            let state = WeeklyForecastFeature.State(weather: weather)
            #expect(state.dailyForecasts == forecasts)
        }

        @Test("daily が空の Weather では dailyForecasts が空になる")
        func emptyDailyResultsInEmptyForecasts() {
            let state = WeeklyForecastFeature.State(weather: .stub(daily: []))
            #expect(state.dailyForecasts.isEmpty)
        }
    }

    @MainActor
    struct ReducerTests {
        @Test("onAppear は副作用なし")
        func onAppearHasNoEffect() async {
            let forecasts = [DailyForecast.stub()]
            let store = TestStore(
                initialState: WeeklyForecastFeature.State(weather: .stub(daily: forecasts))
            ) {
                WeeklyForecastFeature()
            }
            await store.send(.onAppear)
        }
    }
}
