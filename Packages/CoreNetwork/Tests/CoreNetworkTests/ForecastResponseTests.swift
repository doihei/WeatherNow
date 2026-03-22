import CoreModels
import Foundation
import Testing
@testable import CoreNetwork

struct ForecastResponseTests {
    // MARK: - Fixture

    private static let validJSON = Data("""
    {
        "current": {
            "time": "2024-01-15T12:00",
            "temperature_2m": 20.5,
            "apparent_temperature": 18.0,
            "relativehumidity_2m": 65,
            "weathercode": 0,
            "windspeed_10m": 15.0
        },
        "hourly": {
            "time": ["2024-01-15T00:00", "2024-01-15T01:00", "2024-01-15T02:00"],
            "temperature_2m": [10.0, 11.0, 12.0],
            "precipitation": [0.0, 0.2, 0.0],
            "weathercode": [0, 61, 3]
        },
        "daily": {
            "time": ["2024-01-15", "2024-01-16"],
            "temperature_2m_max": [22.0, 20.0],
            "temperature_2m_min": [8.0, 9.0],
            "precipitation_probability_max": [10, 70],
            "weathercode": [0, 63]
        }
    }
    """.utf8)

    // MARK: - Current

    @Test("current を正しく CurrentWeather に変換する")
    func current() throws {
        let response = try JSONDecoder().decode(ForecastResponse.self, from: Self.validJSON)
        let weather = response.toWeather()

        #expect(weather.current.temperature == 20.5)
        #expect(weather.current.feelsLike == 18.0)
        #expect(weather.current.humidity == 65)
        #expect(weather.current.windSpeed == 15.0)
        #expect(weather.current.code == .clearSky)
    }

    // MARK: - Hourly

    @Test("hourly を正しく HourlyForecast の配列に変換する")
    func hourly() throws {
        let response = try JSONDecoder().decode(ForecastResponse.self, from: Self.validJSON)
        let weather = response.toWeather()

        #expect(weather.hourly.count == 3)
        #expect(weather.hourly[0].temperature == 10.0)
        #expect(weather.hourly[0].precipitation == 0.0)
        #expect(weather.hourly[0].code == .clearSky)
        #expect(weather.hourly[1].code == .lightRain)
        #expect(weather.hourly[2].code == .overcast)
    }

    @Test("hourly の不正な日時文字列はスキップされる")
    func hourlyInvalidDateSkipped() throws {
        let json = Data("""
        {
            "current": {
                "time": "2024-01-15T12:00",
                "temperature_2m": 20.0,
                "apparent_temperature": 18.0,
                "relativehumidity_2m": 60,
                "weathercode": 0,
                "windspeed_10m": 10.0
            },
            "hourly": {
                "time": ["invalid-date", "2024-01-15T01:00"],
                "temperature_2m": [10.0, 11.0],
                "precipitation": [0.0, 0.0],
                "weathercode": [0, 0]
            },
            "daily": {
                "time": ["2024-01-15"],
                "temperature_2m_max": [22.0],
                "temperature_2m_min": [8.0],
                "precipitation_probability_max": [10],
                "weathercode": [0]
            }
        }
        """.utf8)

        let response = try JSONDecoder().decode(ForecastResponse.self, from: json)
        let weather = response.toWeather()

        // "invalid-date" はスキップされる → 有効な1件のみ
        #expect(weather.hourly.count == 1)
        #expect(weather.hourly[0].temperature == 11.0)
    }

    // MARK: - Daily

    @Test("daily を正しく DailyForecast の配列に変換する")
    func daily() throws {
        let response = try JSONDecoder().decode(ForecastResponse.self, from: Self.validJSON)
        let weather = response.toWeather()

        #expect(weather.daily.count == 2)
        #expect(weather.daily[0].maxTemp == 22.0)
        #expect(weather.daily[0].minTemp == 8.0)
        #expect(weather.daily[0].precipitationProb == 10)
        #expect(weather.daily[0].code == .clearSky)
        #expect(weather.daily[1].precipitationProb == 70)
        #expect(weather.daily[1].code == .moderateRain)
    }

    @Test("WMOコードが WeatherCode に正しく変換される", arguments: zip(
        [0, 1, 61, 65, 95],
        [WeatherCode.clearSky, .mainlyClear, .lightRain, .heavyRain, .thunderstorm]
    ))
    func wmoCodeConversion(wmoCode: Int, expected: WeatherCode) {
        #expect(WeatherCode(wmoCode: wmoCode) == expected)
    }
}
