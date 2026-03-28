# WeatherNow — CLAUDE.md

## プロジェクト概要

Open-Meteo API を使った iOS 天気予報アプリ。**MVVM + @Observable** と **TCA** の2アーキテクチャで比較実装する学習プロジェクト。

- iOS 17+ / Swift 6（swift-tools-version: 6.2）
- 詳細仕様は [Docs/spec.md](Docs/spec.md) を参照
- API 定義は [Docs/api.md](Docs/api.md) を参照
- アーキテクチャ設計は [Docs/architecture.md](Docs/architecture.md) を参照

## SPM モジュール構成

| モジュール | 役割 | 依存先 |
|---|---|---|
| CoreModels | データモデル | なし |
| CoreNetwork | APIClient | CoreModels |
| CoreUI | 共通UIコンポーネント | CoreModels |
| WeatherDomain | Repository・Service | CoreModels, CoreNetwork |
| WeatherFeature | View・ViewModel / Feature | WeatherDomain, CoreUI |

依存方向は **下向きのみ**。ファイル・ディレクトリ構成の詳細は [`.claude/rules/swift-file-structure.md`](.claude/rules/swift-file-structure.md) を参照。

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
make bootstrap           # SwiftFormat・SwiftLint を release ビルド（初回のみ）
make format              # SwiftFormat でコード整形
make lint                # SwiftLint でコード検査
make test                # 全パッケージのテストを実行
make test-models         # CoreModels のみ
make test-network        # CoreNetwork のみ
make test-domain         # WeatherDomain のみ
make test-feature        # WeatherFeature（MVVM + TCA）
make test-feature-mvvm   # WeatherFeature MVVM のみ
make test-feature-tca    # WeatherFeature TCA のみ
```

Xcode ビルド時は Run Script Phase で SwiftFormat（lint）・SwiftLint が自動実行される。

## アーキテクチャ方針

詳細は [Docs/architecture.md](Docs/architecture.md) を参照。

- **MVVM**：`@Observable` ViewModel + NavigationPath + TaskKey。DI は init 引数で Protocol 注入。
- **TCA**：`@Reducer` + StackState + CancelID。DI は `@Dependency`（`testValue` 必須）。

## コーディング規約

詳細は [`.claude/rules/`](.claude/rules/) を参照。

## 現在の実装状況

- **Phase 1 完了**：CoreModels・CoreNetwork・CoreUI
- **Phase 2 完了**：WeatherDomain（WeatherRepository / LocationService / AppSettingsService）
- **Phase 3 完了**：WeatherFeature MVVM ViewModels（AppViewModel / CurrentWeatherViewModel / WeeklyForecastViewModel / CitySearchViewModel / CityListViewModel）
- **Phase 4 以降**：WeatherFeature TCA・UI 実装は未着手
