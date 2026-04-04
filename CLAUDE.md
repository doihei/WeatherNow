# WeatherNow

Open-Meteo API を使った iOS 天気予報アプリ。MVVM + TCA の2アーキテクチャ比較実装。

- iOS 17+ / Swift 6（swift-tools-version: 6.2）
- 仕様: @Docs/spec.md / API: @Docs/api.md / 設計: @Docs/architecture.md

## モジュール構成

`CoreModels → CoreNetwork → WeatherDomain → WeatherFeature`、`CoreModels → CoreUI`。依存は下向きのみ。
詳細は [`.claude/rules/`](.claude/rules/) 参照。

## 開発コマンド

```bash
make bootstrap          # SwiftFormat・SwiftLint を release ビルド（初回のみ）
make format             # コード整形
make lint               # コード検査
make test               # 全テスト
make test-feature-mvvm  # MVVM のみ
make test-feature-tca   # TCA のみ
```

## アーキテクチャ

- **MVVM**：`@Observable` ViewModel + NavigationPath。DI は `@Dependency`（swift-dependencies）で注入
- **TCA**：`@Reducer` + StackState + CancelID。DI は `@Dependency`（`testValue` 必須）

## 実装状況

- **Phase 1–2 完了**：CoreModels・CoreNetwork・CoreUI・WeatherDomain
- **Phase 3 完了**：WeatherFeature MVVM ViewModels
- **Phase 4 完了**：WeatherFeature TCA Features（36テスト）
- **Phase 5 以降**：UI 実装は未着手
