---
name: add-tests
description: 対象モジュールの Swift Testing テストを追加・更新する。swift-testing-conventions.md に従い、テスト設計からテスト実行・結果報告まで行う。
argument-hint: "[モジュール名 or 型名]"
---

# add-tests: Swift Testing テスト追加・更新

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
   `.claude/rules/swift-testing-conventions.md` に従って実装する（命名・構成・アサーション・DI パターンはすべてそちらを参照）。
   テストファイルの配置先は下記テーブルを参照。

5. **テスト実行**
   対応する `make test-*` コマンドを実行し、すべてパスすることを確認する。
   失敗した場合はエラーを読んで修正し、再実行する。

6. **結果報告**
   追加・更新したテストファイルと、テスト件数をユーザーに報告する。

---

## テストファイルの配置先

| モジュール | テストディレクトリ | make コマンド |
|---|---|---|
| CoreModels | `Packages/CoreModels/Tests/CoreModelsTests/` | `make test-models` |
| CoreNetwork | `Packages/CoreNetwork/Tests/CoreNetworkTests/` | `make test-network` |
| WeatherDomain | `Packages/WeatherDomain/Tests/WeatherDomainTests/` | `make test-domain` |
| WeatherFeature (MVVM) | `Packages/WeatherFeature/Tests/WeatherFeatureMVVMTests/` | `make test-feature-mvvm` |
| WeatherFeature (TCA) | `Packages/WeatherFeature/Tests/WeatherFeatureTCATests/` | `make test-feature-tca` |

`make test-feature` で MVVM・TCA 両方を、`make test` で全パッケージを実行する。

---

## テストダブルのパターン

### CoreNetwork 層（WeatherDomain のテスト用）

`CoreNetwork/Clients/` に `TestWeatherAPIClient` / `TestGeocodingAPIClient` を定義済み。
クロージャでふるまいを注入する。

```swift
try await withDependencies {
    $0.weatherAPIClient = TestWeatherAPIClient { _, _ in Weather.stub() }
    $0.geocodingAPIClient = TestGeocodingAPIClient { _, _ in [] }
} operation: {
    let repo = WeatherRepository()
    // ...
}
// 引数なし（常にデフォルト値）の場合はデフォルト初期化子を使う
let client = TestGeocodingAPIClient()
```

### WeatherFeature (MVVM) 層（ViewModel のテスト用）

`Tests/WeatherFeatureMVVMTests/Stubs.swift` に以下のスタブを定義済み。

```swift
// StubWeatherRepository — weatherStub / searchStub をプロパティで差し替え可能
var repo = StubWeatherRepository()
repo.weatherStub = Weather.stub(temperature: 30.0)

// StubLocationService — location プロパティで差し替え可能
var loc = StubLocationService()
loc.location = (latitude: 34.69, longitude: 135.50)

// HourlyForecast.stub() — time を指定可能（デフォルト: Date()）
let forecast = HourlyForecast.stub(time: Date())
```

永続化サービス（`AppSettingsService` / `CityListService`）はモックを使わず、
UUID 隔離したリアル実装を `withDependencies` で注入して検証する。

```swift
let cityListDefaults = try #require(UserDefaults(suiteName: "test_\(UUID().uuidString)"))
let vm = withDependencies {
    $0.weatherRepository = StubWeatherRepository()
    $0.cityListService = CityListService(defaults: cityListDefaults)
} operation: { CityListViewModel() }

vm.add(.stub(id: 1))
// 永続化の検証はサービスに直接問い合わせる
#expect(CityListService(defaults: cityListDefaults).load().count == 1)
```

スタブに存在しない Protocol を新たにテストするときは `Stubs.swift` に追記する。

### WeatherFeature (TCA) 層（Feature のテスト）

`Tests/WeatherFeatureTCATests/Stubs.swift` に以下のスタブを定義済み。

```swift
// StubWeatherRepository — weatherStub / searchStub をプロパティで差し替え可能
var repo = StubWeatherRepository()
repo.weatherStub = Weather.stub(temperature: 30.0)

// StubLocationService — location プロパティで差し替え可能

// HourlyForecast.stub() — time を指定可能（デフォルト: Date()）
let forecast = HourlyForecast.stub(time: Date())
```

TestStore は `@MainActor` が必要。テストグループ struct にも `@MainActor` を付与する。

```swift
@MainActor
struct LoadTests {
    @Test("...")
    func someTest() async {
        let store = TestStore(initialState: SomeFeature.State()) {
            SomeFeature()
        } withDependencies: {
            $0.weatherRepository = StubWeatherRepository()
        }
        // 複数ステップのテストは exhaustivity = .off で中間状態を省略
        store.exhaustivity = .off
        await store.send(.someAction)
        await store.receive(\.response.success) { $0.result = ... }
    }
}
```

debounce のテストは `TestClock` を使い時間を手動制御する。

```swift
let clock = TestClock()
let store = TestStore(...) withDependencies: {
    $0.continuousClock = clock
}
await store.send(.queryChanged("東京")) { $0.isSearching = true }
await clock.advance(by: .milliseconds(300))
await store.receive(.searchResponse(.success(...)))
```

インライン `struct` は SwiftLint の nesting 違反になる（型のネストは最大1段）。
テスト用のスタブ struct はファイルのトップレベルに `private struct` として定義する。

---

## 注意事項

- Actor のメソッドは Protocol で `async` にしないと Swift 6 でコンパイルエラーになる
  （`clearCache()` → `clearCache() async` など）
- macOS 14 未満で使えない API は `if #available(macOS 15, iOS 18, *)` でガードする
- Foundation（`UserDefaults`・`IndexSet`・`Date` など）は各テストファイルで明示的に `import Foundation` する
- `WeatherDomain` を使うテストファイルは `import WeatherDomain` を明示する
