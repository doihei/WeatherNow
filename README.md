# WeatherNow

Open-Meteo API を使った iOS 天気予報アプリ。MVVM + @Observable と TCA の2アーキテクチャで比較実装する学習プロジェクト。

- **iOS 17+** / Swift 6
- **API:** Open-Meteo（認証不要・無料）
- **外部ライブラリ:** [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) / [SFSafeSymbols](https://github.com/SFSafeSymbols/SFSafeSymbols) / [swift-dependencies](https://github.com/pointfreeco/swift-dependencies)

## セットアップ

```bash
# SwiftFormat・SwiftLint のビルド（初回のみ）
make bootstrap

# フォーマット
make format

# Lint
make lint

# テスト実行
make test               # 全パッケージ
make test-models        # CoreModels のみ
make test-network       # CoreNetwork のみ
make test-domain        # WeatherDomain のみ
make test-feature       # WeatherFeature（MVVM + TCA）
make test-feature-mvvm  # WeatherFeature MVVM のみ
make test-feature-tca   # WeatherFeature TCA のみ
```

## SPM モジュール構成

```
WeatherNow
├── WeatherFeatureMVVM   ← MVVM 実装
├── WeatherFeatureTCA    ← TCA 実装
├── WeatherDomain        ← Repository・LocationService
├── CoreNetwork          ← APIClient
├── CoreModels           ← データモデル
└── CoreUI               ← 共通コンポーネント
```

## ドキュメント

| ファイル | 内容 |
|---|---|
| [Docs/spec.md](Docs/spec.md) | 画面仕様・データモデル設計 |
| [Docs/api.md](Docs/api.md) | Open-Meteo API エンドポイント・レスポンス定義 |
| [Docs/architecture.md](Docs/architecture.md) | モジュール構成・依存関係・MVVM vs TCA 比較 |
