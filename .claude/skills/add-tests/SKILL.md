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
   `.claude/rules/swift-testing-conventions.md` に従って実装する。
   - 1型1ファイル（`TypeNameTests.swift`）
   - 単一関心の型は `struct TypeNameTests`、複数の関心事は `enum` + nested `struct`
   - `@Suite` デコレータは付けない
   - `@Test("日本語で意図を記述する")` で命名する
   - テストダブルは後述のパターンを使う
   - フィクスチャは `private extension Model { static func stub(...) }` で定義する
   - 非同期カウンタは `actor CallCounter` を使う
   - `UserDefaults` を使うテストは `suiteName: "test_\(UUID().uuidString)"` で分離する
   - テストファイルの配置先はモジュールごとに異なる（後述）

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

```swift
// CoreNetwork/Clients/ に定義済み。クロージャで注入する。
let client = TestWeatherAPIClient { lat, lon in
    return Weather.stub()
}

let client = TestGeocodingAPIClient { name, count in
    return [GeocodingResult(...)]
}
// 引数なし（常に空配列）の場合はデフォルト初期化子を使う
let client = TestGeocodingAPIClient()
```

### WeatherFeature 層（ViewModel のテスト用）

`Tests/WeatherFeatureMVVMTests/Stubs.swift` に共有スタブを定義済み。
新しいテストファイルは定義済みの型をそのまま使う。

```swift
// StubWeatherRepository — weatherStub / searchStub をプロパティで差し替え可能
var repo = StubWeatherRepository()
repo.weatherStub = Weather.stub(temperature: 30.0)

// StubLocationService — location プロパティで差し替え可能
var loc = StubLocationService()
loc.location = (latitude: 34.69, longitude: 135.50)

// StubAppSettingsService — final class。savedSettings で保存内容を検証できる
let service = StubAppSettingsService(settings: AppSettings(temperatureUnit: .fahrenheit, ...))
vm.saveSettings()
#expect(service.savedSettings == expected)

// StubCityListService — final class。savedCities で保存内容を検証できる
let cityService = StubCityListService(cities: [])
let vm = CityListViewModel(repository: repo, cityListService: cityService)
vm.add(.stub(id: 1))
#expect(cityService.savedCities?.count == 1)
```

スタブに存在しない Protocol を新たにテストするときは `Stubs.swift` に追記する。

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

---

## @MainActor ViewModel のテストパターン

ViewModel が `@MainActor` の場合、テスト struct にも `@MainActor` を付与する。

```swift
@MainActor
struct CityListViewModelTests {
    private func makeFreshViewModel(
        repository: StubWeatherRepository = StubWeatherRepository(),
        cityListService: StubCityListService = StubCityListService()
    ) -> CityListViewModel {
        CityListViewModel(repository: repository, cityListService: cityListService)
    }

    @Test("add で都市が1件追加される")
    func addCity() {
        let vm = makeFreshViewModel()
        vm.add(.stub(id: 1))
        #expect(vm.cities.count == 1)
    }
}
```

**非同期 Task を待つ場合** — ViewModel 内の `Task { }` は即時完了するスタブを使っても
非同期で走るため、`Task.sleep` で待機する。

```swift
vm.loadAllWeather()
try await Task.sleep(for: .milliseconds(100))
#expect(vm.citiesWeather[1] != nil)
```

---

## フィクスチャの定義場所

- **WeatherDomain テスト**：各テストファイル内に `private extension` で定義
- **WeatherFeature テスト**：`Stubs.swift` に `extension` として定義済み

```swift
// Stubs.swift に定義済みのスタブファクトリ
Weather.stub(temperature: 25.0, daily: [])
GeocodingResult.stub(id: 1, name: "東京")
DailyForecast.stub(date: someDate)
```

---

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

---

## 注意事項

- XCTest は使わない。`import Testing` のみ使用する
- `@Suite` デコレータは Xcode が除去するため付けない
- `@MainActor` ViewModel のテスト struct には `@MainActor` を付与する
- Actor のメソッドは Protocol で `async` にしないと Swift 6 でコンパイルエラーになる
  （`clearCache()` → `clearCache() async` など）
- macOS 14 未満で使えない API は `if #available(macOS 15, iOS 18, *)` でガードする
- `swift test` が通るよう `Package.swift` の `platforms` に `.macOS(.v14)` を含める
- テストターゲットの `dependencies` に必要なモジュールをすべて明示する
- Foundation（`UserDefaults`・`IndexSet`・`Date` など）は各テストファイルで明示的に `import Foundation` する
