# WeatherNow — CLAUDE.md

## プロジェクト概要

Open-Meteo API を使った iOS 天気予報アプリ。**MVVM + @Observable** と **TCA** の2アーキテクチャで比較実装する学習プロジェクト。

- iOS 17+ / Swift 6（swift-tools-version: 6.2）
- 詳細仕様は [Docs/spec.md](Docs/spec.md) を参照
- API 定義は [Docs/api.md](Docs/api.md) を参照
- アーキテクチャ設計は [Docs/architecture.md](Docs/architecture.md) を参照

## ディレクトリ構成

```
WeatherNow/
├── Docs/
│   └── spec.md                   # 詳細仕様書（画面・API・データモデル）
├── Packages/                     # SPMモジュール群
│   ├── CoreModels/               # データモデル（依存なし）
│   │   └── Sources/CoreModels/
│   │       ├── City/             # City, GeocodingResult
│   │       ├── Errors/           # WeatherError
│   │       ├── Settings/         # AppSettings
│   │       └── Weather/          # Weather, CurrentWeather, DailyForecast, HourlyForecast, WeatherCode
│   ├── CoreNetwork/              # APIClient（→ CoreModels）
│   │   └── Sources/CoreNetwork/
│   │       ├── Clients/          # APIClient, LiveXxxClient, TestXxxClient
│   │       ├── Endpoints/        # OpenMeteoEndpoint（URL・パラメータ定義）
│   │       ├── Protocols/        # WeatherAPIClientProtocol, GeocodingAPIClientProtocol
│   │       └── Responses/        # ForecastResponse, GeocodingResponse
│   ├── CoreUI/                   # 共通UIコンポーネント（→ CoreModels）
│   │   └── Sources/CoreUI/
│   │       └── Extensions/       # WeatherCode+SFSymbol など
│   ├── WeatherDomain/            # Repository・LocationService（→ CoreModels, CoreNetwork）
│   └── WeatherFeature/           # UI層（→ WeatherDomain, CoreUI）
│       ├── Sources/WeatherFeatureMVVM/   # MVVM実装
│       └── Sources/WeatherFeatureTCA/    # TCA実装
├── Tools/                        # 開発ツール（SwiftFormat・SwiftLint）
│   └── Package.swift
├── WeatherNow/                   # Xcodeアプリ本体
│   ├── Sources/WeatherNowApp.swift
│   └── WeatherNow.xcodeproj/
├── WhetherNow.xcworkspace        # ルートワークスペース
├── .swiftformat                  # SwiftFormat 設定
├── .swiftlint.yml                # SwiftLint 設定
└── Makefile                      # 開発コマンド
```

依存方向は **下向きのみ**（WeatherFeature → WeatherDomain → CoreNetwork → CoreModels）。

## 外部ライブラリ

| ライブラリ | バージョン | 使用箇所 |
|-----------|-----------|---------|
| swift-composable-architecture | 1.17.0+ | WeatherFeatureTCA のみ |
| SFSafeSymbols | 5.3.0+ | CoreUI のみ |
| SwiftFormat | 0.54.0+ | Tools（開発ツール） |
| SwiftLint | 0.57.0+ | Tools（開発ツール） |

Swift Charts・CoreLocation はシステムフレームワークのため SPM 不要。

## 開発コマンド

```bash
make bootstrap   # SwiftFormat・SwiftLint を release ビルド（初回のみ）
make format      # SwiftFormat でコード整形
make lint        # SwiftLint でコード検査
```

Xcode ビルド時は Run Script Phase で SwiftFormat（lint）・SwiftLint が自動実行される。

## アーキテクチャ方針

### MVVM（WeatherFeatureMVVM）
- ViewModel は `@Observable` で定義
- 非同期処理は `Task` + TaskKey（Dictionary管理）
- ナビゲーションは `AppViewModel` が `NavigationPath` を保持（タブごと）
- DI は init 引数で Protocol を注入
- debounce は `Task.sleep` + `checkCancellation()` で実装

### TCA（WeatherFeatureTCA）
- 各画面を `@Reducer` で定義
- 非同期処理は `.run { }` + `.cancellable(id: CancelID)`
- ナビゲーションは `RootFeature` が `StackState` を管理
- DI は `@Dependency` で注入（`testValue` 必須）
- debounce は `.debounce(id:, for:, scheduler:)` で実装

## コーディング規約

詳細は [`.claude/rules/`](.claude/rules/) を参照。

- モデルはすべて `struct + Sendable + Equatable`
- エラー型は `WeatherError` enum に集約（[Docs/spec.md](Docs/spec.md) §5.2 参照）
- WMOコードの変換は `WeatherCode` enum で行う
- SF Symbols は SFSafeSymbols を使って型安全に扱う（CoreUI のみで使用）
- API の URL・クエリパラメータは `Endpoint` enum に集約し、クライアント実装内に直書きしない

## 現在の実装状況

- **Phase 1 完了**：CoreModels・CoreNetwork の実装済み
  - CoreModels：Weather / City / AppSettings / WeatherCode / WeatherError
  - CoreNetwork：APIClient / WeatherAPIClient / GeocodingAPIClient / OpenMeteoEndpoint / ForecastResponse / GeocodingResponse
  - CoreUI：WeatherCode+SFSymbol（SFSafeSymbols 使用）
- **Phase 2 以降**：WeatherDomain・WeatherFeature（MVVM/TCA）は未着手
