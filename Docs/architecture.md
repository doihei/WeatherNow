# アーキテクチャ設計

WeatherNow のモジュール構成・依存関係・各レイヤーの責務を記述する。

---

## 1. モジュール依存グラフ

```
WeatherFeatureMVVM ─┐
WeatherFeatureTCA  ─┤→ WeatherDomain → CoreNetwork → CoreModels
                    └→ CoreUI                       ↗
```

依存は**下向きのみ**。上位モジュールから下位モジュールへの参照のみ許可する。

---

## 2. 各モジュールの責務

| モジュール | 責務 | 主なファイル |
|---|---|---|
| CoreModels | データモデル・エラー型・設定値 | Weather, City, AppSettings, WeatherCode, WeatherError |
| CoreNetwork | HTTP 通信・レスポンス変換 | APIClient, WeatherAPIClient, GeocodingAPIClient, OpenMeteoEndpoint |
| CoreUI | 共通 UI コンポーネント・モデルへの UI extension | WeatherCode+SFSymbol |
| WeatherDomain | Repository・LocationService（未実装） | — |
| WeatherFeatureMVVM | MVVM 実装の View・ViewModel（未実装） | — |
| WeatherFeatureTCA | TCA 実装の View・Feature（未実装） | — |

---

## 3. CoreModels ファイル構成

```
CoreModels/
├── City/        — City（登録都市）, GeocodingResult（検索結果）
├── Errors/      — WeatherError
├── Settings/    — AppSettings（TemperatureUnit / WindUnit / Theme をネスト）
└── Weather/     — Weather, CurrentWeather, DailyForecast, HourlyForecast, WeatherCode
```

---

## 4. CoreNetwork ファイル構成

```
CoreNetwork/
├── Clients/     — APIClient（ベース HTTP）, LiveXxxClient, TestXxxClient
├── Endpoints/   — OpenMeteoEndpoint（URL・クエリパラメータ定義）
├── Protocols/   — WeatherAPIClientProtocol, GeocodingAPIClientProtocol
└── Responses/   — ForecastResponse, GeocodingResponse（Decodable）
```

---

## 5. MVVM vs TCA 実装方針

| 関心事 | MVVM（@Observable） | TCA（@Reducer） |
|---|---|---|
| 状態管理 | `@Observable` ViewModel | `State` struct |
| 非同期処理 | `Task` + TaskKey | `.run { }` + `.cancellable(id:)` |
| ナビゲーション | `AppViewModel` が `NavigationPath` を保持 | `RootFeature` が `StackState` を管理 |
| DI | init 引数で Protocol を注入 | `@Dependency` で注入（`testValue` 必須） |
| debounce | `Task.sleep` + `checkCancellation()` | `.debounce(id:, for:, scheduler:)` |
| 都市リスト | `[City]` を直接管理 | `IdentifiedArrayOf` + `.forEach` |

---

## 6. エラーハンドリング

全エラーは `WeatherError` に集約する。

| case | 説明 |
|---|---|
| `locationDenied` | 位置情報権限が拒否されている |
| `locationUnavailable` | 位置情報の取得失敗 |
| `networkFailure(String)` | URLError などネットワーク系エラー |
| `decodingFailure` | JSON デコード失敗 |
| `cityLimitReached` | 登録都市数が上限（10 件）超過 |

---

## 7. SF Symbols 利用方針

SF Symbols は `SFSafeSymbols` ライブラリを使って型安全に扱う。
マッピング定義は `CoreUI` の `WeatherCode+SFSymbol.swift` に集約し、`CoreModels` には置かない。

```swift
// CoreUI/Extensions/WeatherCode+SFSymbol.swift
extension WeatherCode {
    var symbol: SFSymbol { ... }
}
```
