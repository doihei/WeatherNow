# add-tests: Swift Testing テスト追加・更新

対象モジュールのソースコードを読み込み、`.claude/rules/swift-testing-conventions.md` に従って Swift Testing のテストを追加または更新するスキル。

## 手順

1. **対象の把握**
   ユーザーの指示から対象モジュール・型・機能を特定する。
   - 指定がない場合は `git status` と `git diff` で未テストの変更を洗い出す
   - 既存テストファイルがあれば Read で確認し、重複・漏れを把握する

2. **ソースコードの読み込み**
   テスト対象の型・Protocol・実装ファイルをすべて Read する。
   - 公開 API（`public` な型・メソッド・プロパティ）を網羅的に把握する
   - Protocol の要件・Actor の状態変化・エラーケースに注目する

3. **テスト設計**
   以下の観点でテストケースを設計する。
   - **正常系**：典型的な入力と期待される出力
   - **境界値**：空・nil・ゼロ・最大値など
   - **異常系**：エラーが発生するケース・エラーの型と内容
   - **副作用**：キャッシュ・状態変化・API 呼び出し回数など
   - **パラメータ化**：複数パターンをまとめられるケースは `zip` でまとめる

4. **テストファイルの作成・更新**
   `.claude/rules/swift-testing-conventions.md` に従って実装する。
   - 1型1ファイル（`TypeNameTests.swift`）
   - 単一関心の型は `struct TypeNameTests`、複数の関心事は `enum` + nested `struct`
   - `@Suite` デコレータは付けない
   - `@Test("日本語で意図を記述する")` で命名する
   - テストダブルは `TestXxxClient` クロージャ注入パターンを使う
   - フィクスチャは `private extension Model { static func stub(...) }` で定義する
   - 非同期カウンタは `actor CallCounter` を使う
   - `UserDefaults` を使うテストは `suiteName: "test_\(UUID().uuidString)"` で分離する
   - テストファイルの配置先：`Packages/<Module>/Tests/<Module>Tests/<TypeName>Tests.swift`

5. **テスト実行**
   対応する `make test-*` コマンドを実行し、すべてパスすることを確認する。
   - `make test-models` — CoreModels
   - `make test-network` — CoreNetwork
   - `make test-domain` — WeatherDomain
   - 失敗した場合はエラーを読んで修正し、再実行する

6. **結果報告**
   追加・更新したテストファイルと、テスト件数をユーザーに報告する。

## テストダブルのパターン

### TestWeatherAPIClient

```swift
// CoreNetwork/Clients/ に定義済み。クロージャで注入する。
let client = TestWeatherAPIClient { lat, lon in
    return Weather.stub()
}
```

### TestGeocodingAPIClient

```swift
let client = TestGeocodingAPIClient { name, count in
    return [GeocodingResult(...)]
}
// 引数なし（常に空配列）の場合はデフォルト初期化子を使う
let client = TestGeocodingAPIClient()
```

### actor CallCounter（非同期呼び出し回数の計測）

```swift
actor CallCounter {
    var count = 0
    func increment() { count += 1 }
}
let counter = CallCounter()
// クロージャ内: await counter.increment()
// 確認: #expect(await counter.count == 1)
```

## エラーテストのパターン

```swift
do {
    _ = try await someMethod()
    Issue.record("エラーがスローされるべき")
} catch let error as WeatherError {
    #expect(error == .expectedCase)
} catch {
    Issue.record("WeatherError 以外がスロー: \(error)")
}
```

## 注意事項

- XCTest は使わない。`import Testing` のみ使用する
- `@Suite` デコレータは Xcode が除去するため付けない
- Actor のメソッドは Protocol で `async` にしないと Swift 6 でコンパイルエラーになる
  （`clearCache()` → `clearCache() async` など）
- macOS 14 未満で使えない API は `if #available(macOS 15, iOS 18, *)` でガードする
- `swift test` が通るよう `Package.swift` の `platforms` に `.macOS(.v14)` を含める
- テストターゲットの `dependencies` に必要なモジュールをすべて明示する
