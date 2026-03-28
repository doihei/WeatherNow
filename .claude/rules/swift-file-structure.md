---
paths:
  - Packages/**/*.swift
---

# Swift ファイル構成ルール

## 1モデル1ファイル原則

- 1つのモデル・型につき必ず1ファイルを作成する
- 複数の型を1ファイルにまとめない

## ディレクトリ構成

### CoreModels (`Packages/CoreModels/Sources/CoreModels/`)

| ディレクトリ | 対象 |
|---|---|
| `City/` | City, GeocodingResult |
| `Errors/` | WeatherError |
| `Settings/` | AppSettings |
| `Weather/` | Weather, CurrentWeather, DailyForecast, HourlyForecast, WeatherCode |

### CoreNetwork (`Packages/CoreNetwork/Sources/CoreNetwork/`)

| ディレクトリ | 対象 |
|---|---|
| `Clients/` | APIClient, LiveXxxClient, TestXxxClient |
| `Endpoints/` | OpenMeteoEndpoint など URL・パラメータ定義 |
| `Protocols/` | XxxProtocol |
| `Responses/` | Decodable なレスポンス構造体 |

### WeatherDomain (`Packages/WeatherDomain/Sources/WeatherDomain/`)

| ディレクトリ | 対象 |
|---|---|
| `Location/` | LocationService, LocationServiceProtocol |
| `Repository/` | WeatherRepository, WeatherRepositoryProtocol |
| `Settings/` | AppSettingsService, AppSettingsServiceProtocol |

Protocol と実装は同じディレクトリに配置する（CoreNetwork の `Protocols/` 分離とは異なる）。

### CoreUI (`Packages/CoreUI/Sources/CoreUI/`)

| ディレクトリ | 対象 |
|---|---|
| `Extensions/` | 他モジュール型への extension |

### WeatherFeature (`Packages/WeatherFeature/`)

ソースは **画面モジュール単位**のサブディレクトリで管理する。Phase 5 で View を追加する際は同じディレクトリに置く。

```
Sources/
├── MVVM/               # SPM target: WeatherFeatureMVVM
│   ├── App/            # AppViewModel
│   ├── CurrentWeather/ # CurrentWeatherViewModel（+ 将来: CurrentWeatherView）
│   ├── WeeklyForecast/ # WeeklyForecastViewModel
│   ├── CitySearch/     # CitySearchViewModel
│   └── CityList/       # CityListViewModel
└── TCA/                # SPM target: WeatherFeatureTCA（Phase 4）

Tests/
├── WeatherFeatureMVVMTests/  # MVVM ViewModel テスト
│   └── Stubs.swift           # 共有スタブ・ファクトリ
└── WeatherFeatureTCATests/   # TCA Feature テスト（Phase 4）
```

SPM target のデフォルトパス（`Sources/<TargetName>/`）と異なるため、Package.swift で `path:` を明示する。

```swift
.target(name: "WeatherFeatureMVVM", ..., path: "Sources/MVVM")
.target(name: "WeatherFeatureTCA",  ..., path: "Sources/TCA")
.testTarget(name: "WeatherFeatureMVVMTests", ..., path: "Tests/WeatherFeatureMVVMTests")
.testTarget(name: "WeatherFeatureTCATests",  ..., path: "Tests/WeatherFeatureTCATests")
```

## ファイル命名規則

- 通常のファイル: `TypeName.swift`
- Extension ファイル: `Type+Feature.swift`（例: `WeatherCode+SFSymbol.swift`）
- Protocol ファイル: `TypeNameProtocol.swift`（例: `WeatherAPIClientProtocol.swift`）
- テスト共有スタブ: `Stubs.swift`（各テストターゲットに1ファイル）
