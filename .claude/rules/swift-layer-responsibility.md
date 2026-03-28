---
paths:
  - Packages/**/*.swift
  - "**/Package.swift"
---

# Swift レイヤー責務ルール

## モジュール依存方向

依存は下向きのみ。逆方向の依存は禁止。

```
WeatherFeature (MVVM / TCA)
    └→ WeatherDomain
        └→ CoreNetwork
            └→ CoreModels
CoreUI
    └→ CoreModels
```

## 各モジュールの責務

| モジュール | 置くもの | 置かないもの |
|---|---|---|
| CoreModels | データモデル、エラー型、設定値 | UI依存のコード、ネットワーク処理 |
| CoreNetwork | APIクライアント、レスポンス変換 | UI処理、ビジネスロジック |
| CoreUI | 共通UIコンポーネント、モデルへのUI extension | ネットワーク処理、ビジネスロジック |
| WeatherDomain | Repository、LocationService | UI処理 |
| WeatherFeature | View、ViewModel / Feature | ネットワーク直接呼び出し |

## UI関心事の判断基準

**CoreUI に置く（UIフレームワーク依存）**
- SF Symbols マッピング（`SFSymbol` 型を返すもの）
- SwiftUI コンポーネント

**CoreModels に残す（UI以外でも使用可能）**
- 表示テキスト・ラベル（通知・ログ・Siri でも使用するため）
- 単位変換ロジック

## 外部ライブラリの依存先

| ライブラリ | 依存させるモジュール |
|---|---|
| SFSafeSymbols | CoreUI のみ |
| swift-composable-architecture | WeatherFeatureTCA のみ |
