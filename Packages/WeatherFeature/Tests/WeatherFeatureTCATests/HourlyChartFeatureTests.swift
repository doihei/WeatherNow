import ComposableArchitecture
import CoreModels
import Foundation
import Testing
@testable import WeatherFeatureTCA

// MARK: - HourlyChartFeatureTests

@MainActor
struct HourlyChartFeatureTests {
    @Test("onAppear は副作用を起こさない")
    func onAppearHasNoSideEffect() async {
        let forecasts = [HourlyForecast.stub(), HourlyForecast.stub()]
        let weather = Weather(
            current: CurrentWeather(
                temperature: 20, feelsLike: 18, humidity: 55, windSpeed: 10, code: .clearSky
            ),
            hourly: forecasts,
            daily: []
        )
        let store = TestStore(
            initialState: HourlyChartFeature.State(weather: weather)
        ) {
            HourlyChartFeature()
        }

        await store.send(.onAppear)
    }

    @Test("State は Weather の hourly プロパティを保持する")
    func stateHoldsHourlyForecasts() {
        let forecasts = [
            HourlyForecast.stub(time: Date()),
            HourlyForecast.stub(time: Date().addingTimeInterval(3600)),
            HourlyForecast.stub(time: Date().addingTimeInterval(7200)),
        ]
        let weather = Weather(
            current: CurrentWeather(
                temperature: 20, feelsLike: 18, humidity: 55, windSpeed: 10, code: .clearSky
            ),
            hourly: forecasts,
            daily: []
        )

        let state = HourlyChartFeature.State(weather: weather)

        #expect(state.hourlyForecasts == forecasts)
    }
}
