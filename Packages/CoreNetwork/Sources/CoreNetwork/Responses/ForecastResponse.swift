import CoreModels
import Foundation

// MARK: - ForecastCurrentResponse

struct ForecastCurrentResponse: Decodable {
    let time: String
    let temperature2m: Double
    let apparentTemperature: Double
    let relativehumidity2m: Int
    let weathercode: Int
    let windspeed10m: Double

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case relativehumidity2m = "relativehumidity_2m"
        case weathercode
        case windspeed10m = "windspeed_10m"
    }
}

// MARK: - ForecastHourlyResponse

struct ForecastHourlyResponse: Decodable {
    let time: [String]
    let temperature2m: [Double]
    let precipitation: [Double]
    let weathercode: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case precipitation
        case weathercode
    }
}

// MARK: - ForecastDailyResponse

struct ForecastDailyResponse: Decodable {
    let time: [String]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let precipitationProbabilityMax: [Int]
    let weathercode: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationProbabilityMax = "precipitation_probability_max"
        case weathercode
    }
}

// MARK: - ForecastResponse（天気APIレスポンス）

struct ForecastResponse: Decodable {
    let current: ForecastCurrentResponse
    let hourly: ForecastHourlyResponse
    let daily: ForecastDailyResponse
}

// MARK: - ForecastResponse → Weather 変換

extension ForecastResponse {
    func toWeather() -> Weather {
        let hourlyFormatter = DateFormatter()
        hourlyFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        hourlyFormatter.locale = Locale(identifier: "en_US_POSIX")

        let dailyFormatter = DateFormatter()
        dailyFormatter.dateFormat = "yyyy-MM-dd"
        dailyFormatter.locale = Locale(identifier: "en_US_POSIX")

        let currentWeather = CurrentWeather(
            temperature: current.temperature2m,
            feelsLike: current.apparentTemperature,
            humidity: current.relativehumidity2m,
            windSpeed: current.windspeed10m,
            code: WeatherCode(wmoCode: current.weathercode)
        )

        let hourlyForecasts = zip(hourly.time.indices, hourly.time).compactMap { index, timeStr -> HourlyForecast? in
            guard let date = hourlyFormatter.date(from: timeStr) else { return nil }
            return HourlyForecast(
                time: date,
                temperature: hourly.temperature2m[index],
                precipitation: hourly.precipitation[index],
                code: WeatherCode(wmoCode: hourly.weathercode[index])
            )
        }

        let dailyForecasts = zip(daily.time.indices, daily.time).compactMap { index, timeStr -> DailyForecast? in
            guard let date = dailyFormatter.date(from: timeStr) else { return nil }
            return DailyForecast(
                date: date,
                maxTemp: daily.temperature2mMax[index],
                minTemp: daily.temperature2mMin[index],
                precipitationProb: daily.precipitationProbabilityMax[index],
                code: WeatherCode(wmoCode: daily.weathercode[index])
            )
        }

        return Weather(current: currentWeather, hourly: hourlyForecasts, daily: dailyForecasts)
    }
}
