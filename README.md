# WeatherNow

Open-Meteo API を使った iOS 天気予報アプリ。MVVM + @Observable と TCA の2アーキテクチャで比較実装する学習プロジェクト。

- **iOS 17+** / Swift 6
- **API:** Open-Meteo（認証不要・無料）
- **外部ライブラリ:** [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)

## セットアップ

```bash
# SwiftFormat・SwiftLint のビルド（初回のみ）
make bootstrap

# フォーマット
make format

# Lint
make lint
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

詳細は [Docs/spec.md](Docs/spec.md) を参照。
