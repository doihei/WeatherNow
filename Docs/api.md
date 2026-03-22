# Open-Meteo API リファレンス

WeatherNow で使用する Open-Meteo API のエンドポイント・パラメータ・レスポンス定義。
アプリ内では `OpenMeteoEndpoint` enum を通じて URL を生成する。

---

## 1. 天気取得（forecast）

`GET https://api.open-meteo.com/v1/forecast`

### クエリパラメータ

| パラメータ | 型 | 値 |
|---|---|---|
| latitude | Double | 緯度 |
| longitude | Double | 経度 |
| current | String | `temperature_2m,apparent_temperature,relativehumidity_2m,weathercode,windspeed_10m` |
| hourly | String | `temperature_2m,precipitation,weathercode` |
| daily | String | `temperature_2m_max,temperature_2m_min,precipitation_probability_max,weathercode` |
| timezone | String | `auto` |
| forecast_days | Int | `7` |

### レスポンス構造

```json
{
  "current": {
    "time": "2024-01-01T12:00",
    "temperature_2m": 22.0,
    "apparent_temperature": 20.5,
    "relativehumidity_2m": 60,
    "weathercode": 0,
    "windspeed_10m": 12.3
  },
  "hourly": {
    "time": ["2024-01-01T00:00"],
    "temperature_2m": [18.0],
    "precipitation": [0.0],
    "weathercode": [0]
  },
  "daily": {
    "time": ["2024-01-01"],
    "temperature_2m_max": [25.0],
    "temperature_2m_min": [15.0],
    "precipitation_probability_max": [10],
    "weathercode": [0]
  }
}
```

### Swift モデルへの変換

`ForecastResponse.toWeather()` で `Weather` モデルに変換される。

| API フィールド | Swift モデル |
|---|---|
| `current` | `CurrentWeather` |
| `hourly` | `[HourlyForecast]`（時刻フォーマット: `yyyy-MM-dd'T'HH:mm`） |
| `daily` | `[DailyForecast]`（日付フォーマット: `yyyy-MM-dd`） |
| `weathercode` | `WeatherCode(wmoCode:)` で enum に変換 |

---

## 2. 都市検索（geocoding）

`GET https://geocoding-api.open-meteo.com/v1/search`

### クエリパラメータ

| パラメータ | 型 | 値 |
|---|---|---|
| name | String | 検索キーワード |
| count | Int | 返却件数（デフォルト: 10） |
| language | String | `ja` |

### レスポンス構造

```json
{
  "results": [
    {
      "id": 1850147,
      "name": "東京",
      "country": "日本",
      "latitude": 35.6762,
      "longitude": 139.6503
    }
  ]
}
```

### Swift モデルへの変換

`GeocodingResponse.toResults()` で `[GeocodingResult]` に変換される。
`country` が `null` の場合は空文字列として扱う。

---

## 3. 使用方法（コード例）

```swift
// 天気取得
let url = try OpenMeteoEndpoint.forecast(latitude: 35.6762, longitude: 139.6503).url
let response: ForecastResponse = try await apiClient.get(url: url)
let weather = response.toWeather()

// 都市検索
let url = try OpenMeteoEndpoint.geocoding(name: "東京", count: 10).url
let response: GeocodingResponse = try await apiClient.get(url: url)
let results = response.toResults()
```
