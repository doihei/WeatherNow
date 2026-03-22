# WeatherNow 仕様書 v1.0

アーキテクチャ：MVVM + @Observable / TCA（比較実装）
最低サポート：iOS 17+
API：Open-Meteo（認証不要・無料）

---

## 1. アプリ概要

Open-Meteo API を使用した天気予報アプリ。現在地および登録都市の現在の天気・週間予報を表示する。MVVM と TCA の2アーキテクチャで実装することで設計の違いを体感的に学習することを目的とする。

**API エンドポイント**

- 天気取得：`https://api.open-meteo.com/v1/forecast`
- 都市検索：`https://geocoding-api.open-meteo.com/v1/search`

---

## 2. 画面構成

| No | 画面名 | 役割 | 遷移元 | タブ |
|---|---|---|---|---|
| 1 | CurrentWeatherView | 現在地の天気・今日の予報 | アプリ起動 | 天気 |
| 2 | WeeklyForecastView | 7日間の週間予報詳細 | CurrentWeatherView | 天気 |
| 3 | HourlyChartView | 24時間グラフ表示 | CurrentWeatherView | 天気 |
| 4 | CitySearchView | 都市検索・追加 | CityListView | 都市 |
| 5 | CityListView | 登録都市一覧・並び替え・削除 | タブ直下 | 都市 |
| 6 | SettingsView | 単位設定（℃/℉）・テーマ | 設定タブ直下 | 設定 |

---

## 3. 画面仕様

### 3.1 CurrentWeatherView（現在地の天気）

アプリ起動時のルート画面。位置情報を取得して現在地の天気を表示する。

**表示要素**

| 項目 | 内容 | 説明 | 備考 |
|---|---|---|---|
| 都市名 | テキスト | 現在地の市区町村名 | CoreLocation から取得 |
| 現在気温 | 大テキスト | 現在の気温 | 設定に応じて℃/℉切替 |
| 天気状態 | アイコン＋テキスト | 晴れ・曇り・雨など | WMOコードから変換 |
| 体感温度 | テキスト | apparent_temperature | |
| 湿度 | テキスト | relativehumidity_2m | |
| 風速 | テキスト | windspeed_10m | km/h |
| 今日の予報 | 横スクロール | 3時間ごとの予報 | 24時間分 |

**アクション**

- 引っ張り更新（Pull to Refresh）で天気を再取得
- 「週間予報」ボタン → WeeklyForecastView へ遷移
- 「グラフ」ボタン → HourlyChartView へ遷移
- 位置情報未許可時はエラー表示＋設定へ誘導

**状態管理**

- `loading`：取得中（ProgressView 表示）
- `loaded(Weather)`：取得完了
- `error(WeatherError)`：エラー（リトライボタン表示）

---

### 3.2 WeeklyForecastView（週間予報）

7日間の天気予報を一覧表示する。CurrentWeatherView からの Push 遷移。

**表示要素**

| 項目 | 内容 | 説明 | 備考 |
|---|---|---|---|
| 日付 | テキスト | 曜日＋日付 | |
| 天気アイコン | SF Symbols | WMOコードから変換 | |
| 最高気温 | テキスト | temperature_2m_max | 赤色 |
| 最低気温 | テキスト | temperature_2m_min | 青色 |
| 降水確率 | プログレスバー | precipitation_probability_max | %表示 |

---

### 3.3 HourlyChartView（24時間グラフ）

24時間の気温推移をグラフで表示する。Swift Charts を使用。

**表示要素**

| 項目 | 種別 | 説明 | 備考 |
|---|---|---|---|
| 気温グラフ | Swift Charts LineChart | 1時間ごとの気温推移 | |
| 降水量グラフ | Swift Charts BarChart | 1時間ごとの降水量 | |
| 時刻ラベル | X軸 | 0時〜23時 | |

---

### 3.4 CitySearchView（都市検索）

Open-Meteo の Geocoding API で都市を検索して登録する。

**表示要素**

| 項目 | 種別 | 説明 | 備考 |
|---|---|---|---|
| 検索バー | TextField | 都市名を入力 | 300ms debounce |
| 検索結果リスト | List | 都市名・国・緯度経度 | |
| 追加ボタン | 各行末尾 | 都市を登録 | 重複チェックあり |

**アクション**

- 入力から 300ms 後に自動検索（debounce）
- 追加済みの都市はチェックマーク表示
- 最大登録都市数：10件

---

### 3.5 CityListView（登録都市一覧）

登録済み都市の天気一覧を表示する。都市タブのルート画面。

**表示要素**

| 項目 | 種別 | 説明 | 備考 |
|---|---|---|---|
| 都市カード | List 各行 | 都市名・現在気温・天気状態 | |
| 並び替え | EditButton | ドラッグで並び替え | |
| 削除 | スワイプ | 左スワイプで削除 | |
| 追加ボタン | NavigationBar | CitySearchView へ遷移 | |

---

### 3.6 SettingsView（設定）

アプリ全体の設定を管理する。設定タブのルート画面。

**表示要素**

| 項目 | 種別 | 説明 | 備考 |
|---|---|---|---|
| 温度単位 | Picker | ℃ / ℉ | UserDefaults に保存 |
| 風速単位 | Picker | km/h / mph | UserDefaults に保存 |
| テーマ | Picker | システム / ライト / ダーク | |
| APIバージョン | テキスト | Open-Meteo v1 | |

---

## 4. Open-Meteo API 仕様

### 4.1 現在地天気取得

`GET https://api.open-meteo.com/v1/forecast`

| パラメータ | 型 | 説明 |
|---|---|---|
| latitude | Float | 緯度（CoreLocation から取得） |
| longitude | Float | 経度（CoreLocation から取得） |
| current | String | temperature_2m, apparent_temperature, relativehumidity_2m, weathercode, windspeed_10m |
| hourly | String | temperature_2m, precipitation, weathercode |
| daily | String | temperature_2m_max, temperature_2m_min, precipitation_probability_max, weathercode |
| timezone | String | auto（自動判定） |
| forecast_days | Int | 7 |

### 4.2 都市検索

`GET https://geocoding-api.open-meteo.com/v1/search`

| パラメータ | 型 | 説明 |
|---|---|---|
| name | String | 都市名（検索キーワード） |
| count | Int | 返却件数（最大 10） |
| language | String | ja（日本語名で返却） |

---

## 5. データモデル設計

すべて `struct + Sendable` で設計する。

### 5.1 主要モデル（CoreModels）

| モデル名 | 主要プロパティ | 説明 |
|---|---|---|
| Weather | current, hourly, daily | 天気全データ。API レスポンスから変換 |
| CurrentWeather | temperature, feelsLike, humidity, windSpeed, code | 現在の天気 |
| DailyForecast | date, maxTemp, minTemp, precipitationProb, code | 1日分の予報 |
| HourlyForecast | time, temperature, precipitation, code | 1時間分の予報 |
| City | id, name, country, latitude, longitude | 登録都市。Identifiable + Hashable |
| GeocodingResult | id, name, country, latitude, longitude | 都市検索結果 |
| WeatherCode | Int（WMO コード） | SF Symbols 名・テキストに変換する enum |
| AppSettings | temperatureUnit, windUnit, theme | 設定値。UserDefaults に永続化 |

### 5.2 エラー型（WeatherError）

| case | 説明 |
|---|---|
| locationDenied | 位置情報の権限が拒否されている |
| locationUnavailable | 位置情報の取得に失敗 |
| networkFailure(Error) | ネットワークエラー（下位 URLError をラップ） |
| decodingFailure | API レスポンスのデコード失敗 |
| cityLimitReached | 登録都市数が上限（10件）に達している |

---

## 6. SPM モジュール構成

依存は下向きのみ。

| モジュール | 含まれるもの | 依存先 |
|---|---|---|
| WeatherApp（App Target） | App 構造体・エントリーポイント | 全モジュール |
| WeatherFeature | 各 View・ViewModel / Feature | WeatherDomain / CoreUI |
| WeatherDomain | WeatherRepository（Actor）・LocationService | CoreNetwork / CoreModels |
| CoreNetwork | APIClient・WeatherAPIClient・GeocodingAPIClient | CoreModels |
| CoreModels | Weather・City・AppSettings など全モデル | なし |
| CoreUI | 共通コンポーネント・WeatherIcon・温度表示 | CoreModels |

---

## 7. アーキテクチャ比較実装方針

### 7.1 MVVM + @Observable

- 各画面に対応する ViewModel を `@Observable` で定義
- 非同期処理は `Task` + `TaskKey`（Dictionary 管理）
- ナビゲーションは `AppViewModel` が `NavigationPath` を保持（Tab ごとに分割）
- DI は init 引数で Protocol を注入
- エラーは `errorMessage: String?` で State に保持
- debounce は `Task.sleep` + `checkCancellation()` で実装

### 7.2 TCA

- 各画面を `@Reducer` で定義。State・Action・Reducer を分離
- 非同期処理は `.run { }` + `.cancellable(id: CancelID)`
- ナビゲーションは `RootFeature` が `StackState` を管理
- DI は `@Dependency` で注入。`testValue` を必ず定義
- CityList は `.forEach` + `IdentifiedArrayOf` で各行を管理
- 都市検索の debounce は `.debounce(id:, for:, scheduler:)` で実装

---

## 8. 画面遷移

各タブが独立した NavigationStack を持つ。

```
天気タブ
  └ CurrentWeatherView（ルート）
      ├ → WeeklyForecastView（週間予報ボタンタップ）
      └ → HourlyChartView（グラフボタンタップ）

都市タブ
  └ CityListView（ルート）
      └ → CitySearchView（追加ボタンタップ）

設定タブ
  └ SettingsView（ルート・遷移なし）
```

---

## 9. 実装チェックリスト

### Phase 1：CoreModels・CoreNetwork
- [x] Weather・City・AppSettings など全モデルを `struct + Sendable` で定義
- [x] `WeatherAPIClientProtocol` を定義
- [x] APIClient の `liveValue`・`testValue` を実装
- [x] WMOコード → SF Symbols / テキスト変換ロジック（WeatherCode enum）

### Phase 2：WeatherDomain
- [ ] `WeatherRepository` を Actor で実装（キャッシュ付き）
- [ ] `LocationService` を Actor で実装
- [ ] `WeatherError` を定義（`isRetryable`・`userMessage`）

### Phase 3：MVVM 実装
- [ ] `CurrentWeatherViewModel`
- [ ] `WeeklyForecastViewModel`
- [ ] `CitySearchViewModel`（debounce 300ms）
- [ ] `CityListViewModel`（並び替え・削除）
- [ ] `AppViewModel`（NavigationPath・Tab 管理）

### Phase 4：TCA 実装
- [ ] `CurrentWeatherFeature`
- [ ] `WeeklyForecastFeature`
- [ ] `CitySearchFeature`（`.debounce` 使用）
- [ ] `CityListFeature`（`.forEach` + `IdentifiedArrayOf`）
- [ ] `RootFeature`（`StackState`・TabView 管理）

### Phase 5：UI 実装
- [ ] `HourlyChartView`（Swift Charts）
- [ ] `WeatherIconView`（WMOコード対応）
- [ ] `SettingsView`
- [ ] Pull to Refresh
- [ ] ダークモード対応

---

## 10. 学習ポイント対応表

| 学習内容 | 対応する実装箇所 |
|---|---|
| Actor 再入性（Day 1） | WeatherRepository のキャッシュ設計 |
| TCA vs MVVM（Day 2） | Phase 3・4 の比較実装 |
| SPM モジュール分割（Day 3） | 6モジュール構成 |
| TestClock（Day 4） | debounce・タイムアウトのテスト |
| DI 設計（Day 5） | APIClient の Protocol 化 |
| Swift 6 Sendable（Day 6） | 全モデルの struct + Sendable |
| エラー設計・Task 管理（Day 7） | WeatherError・TaskKey / CancelID |
| NavigationStack（Day 8-9） | RootFeature の StackState / AppViewModel の NavigationPath |
| TabView 設計（Day 10） | 3タブ × 独立 NavigationStack |
| TCA Feature 合成（Day 11） | CityListFeature の forEach | 