---
paths:
  - Packages/**/*.swift
---

# Swift コーディング規約

## モデル定義

- すべてのモデルは `struct + Sendable + Equatable` で定義する
- `class` は使わない（Actor を除く）
- エラー型は `WeatherError` enum に集約する

## アクセスレベル

- モジュール外に公開する型・プロパティ・メソッドにはすべて `public` を付与する
- モジュール内部のみで使う型は `internal`（明示不要）

## ネスト深さ（SwiftLint nesting ルール）

- 型のネストは最大1段まで
- `CodingKeys` が2段ネストになる場合は、外側の struct をトップレベルに引き上げる

```swift
// NG: ForecastResponse > CurrentResponse > CodingKeys で2段
struct ForecastResponse: Decodable {
    struct CurrentResponse: Decodable {
        enum CodingKeys: String, CodingKey { ... }  // nesting violation
    }
}

// OK: CurrentResponse をトップレベルに引き上げ
struct ForecastCurrentResponse: Decodable {
    enum CodingKeys: String, CodingKey { ... }  // 1段
}
struct ForecastResponse: Decodable {
    let current: ForecastCurrentResponse
}
```

## URL・クエリパラメータ

- APIのURL・クエリパラメータは Endpoint enum に集約する
- クライアント実装内にベースURLやクエリを直書きしない

```swift
// OK
let url = try OpenMeteoEndpoint.forecast(latitude: lat, longitude: lon).url

// NG
var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
components.queryItems = [ ... ]
```

## パッケージ設定

- `swift-tools-version: 6.2`
- 最低サポート: `.iOS(.v17)`
- macOS向けにビルドが必要な場合は `.macOS(.v14)` を追加する
