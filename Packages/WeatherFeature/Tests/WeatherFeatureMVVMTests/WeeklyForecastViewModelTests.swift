import CoreModels
import Foundation
import Testing
@testable import WeatherFeatureMVVM

@MainActor
struct WeeklyForecastViewModelTests {
    @Test("init で daily が dailyForecasts に設定される")
    func initSetsDailyForecasts() {
        let daily = [DailyForecast.stub(), DailyForecast.stub()]
        let vm = WeeklyForecastViewModel(weather: .stub(daily: daily))
        #expect(vm.dailyForecasts.count == 2)
    }

    @Test("daily が空のとき dailyForecasts も空")
    func emptyDailyResultsInEmptyForecasts() {
        let vm = WeeklyForecastViewModel(weather: .stub(daily: []))
        #expect(vm.dailyForecasts.isEmpty)
    }

    @Test("dailyForecasts の内容が Weather.daily と一致する")
    func forecastsMatchWeatherDaily() {
        let today = Date()
        let tomorrow = today.addingTimeInterval(86400)
        let daily = [DailyForecast.stub(date: today), DailyForecast.stub(date: tomorrow)]
        let vm = WeeklyForecastViewModel(weather: .stub(daily: daily))
        #expect(vm.dailyForecasts == daily)
    }
}
