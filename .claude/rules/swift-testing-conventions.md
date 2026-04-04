---
paths:
  - Packages/*/Tests/**/*.swift
---

# Swift Testing 規約

## フレームワーク

- **Swift Testing** を使用する（XCTest は使わない）
- `import Testing` を必ず先頭に記述する
- `@testable import ModuleName` でモジュール内部にアクセスする

## テストの構成単位

### 1モデル1ファイル原則

- テストファイルも `TypeNameTests.swift` の命名で1型1ファイルにする
- テスト対象と同じディレクトリ構造にそろえる必要はないが、命名は対応させる

### 単一関心の型

```swift
struct WeatherCodeTests {
    @Test("init(wmoCode:) で既知のWMOコードを正しく変換する", ...)
    func knownWMOCode(...) { ... }
}
```

### 複数の関心事を持つ型

外側を `enum`（インスタンス化不要）、関心事ごとに `struct` でネストする。

```swift
enum AppSettingsTests {
    struct TemperatureUnitTests { ... }
    struct WindUnitTests { ... }
    struct PersistenceTests { ... }
}
```

`@Suite` デコレータは付けない（Xcode の自動整形で除去されるため）。

## テスト命名

- `@Test` の引数に **日本語で意図を記述する**
- 何をテストするかが一文でわかる粒度にする
- メソッド名は英語のキャメルケース

```swift
@Test("fahrenheit 変換式が正しい（0℃→32℉, 100℃→212℉, -40℃→-40℉）")
func fahrenheitConversion(...) { ... }
```

## パラメータ化テスト

入力と期待値を `zip` で組み合わせる。

```swift
@Test("WMOコードが WeatherCode に正しく変換される", arguments: zip(
    [0, 1, 61, 65, 95],
    [WeatherCode.clearSky, .mainlyClear, .lightRain, .heavyRain, .thunderstorm]
))
func wmoCodeConversion(wmoCode: Int, expected: WeatherCode) {
    #expect(WeatherCode(wmoCode: wmoCode) == expected)
}
```

## アサーション

| 場面 | 書き方 |
|---|---|
| 等値・条件チェック | `#expect(value == expected)` |
| nil でないことを確認してアンラップ | `try #require(optional)` |
| エラーが投げられることを確認 | `#expect(throws: SomeError.self) { try ... }` |
| テスト失敗を明示的に記録 | `Issue.record("reason")` |

エラーテストは `do/catch` + `Issue.record` パターンを使う。

```swift
do {
    _ = try await repository.fetchWeather(...)
    Issue.record("エラーが投げられるべき")
} catch let error as WeatherError {
    #expect(error == .networkFailure(underlying: nil))
} catch {
    Issue.record("WeatherError 以外がスロー: \(error)")
}
```

## 非同期テスト

- `async throws` をそのまま使う（XCTest の `expectation` は不要）
- `@Sendable` クロージャ内でカウントを取る場合は `actor` を使う

```swift
actor CallCounter {
    var count = 0
    func increment() { count += 1 }
}

@Test("キャッシュヒット時は API が再呼び出しされない")
func cacheHit() async throws {
    let counter = CallCounter()
    try await withDependencies {
        $0.weatherAPIClient = TestWeatherAPIClient { _, _ in
            await counter.increment()
            return Weather.stub()
        }
    } operation: {
        let repo = WeatherRepository()
        _ = try await repo.fetchWeather(latitude: 35.68, longitude: 139.69)
        _ = try await repo.fetchWeather(latitude: 35.68, longitude: 139.69)
    }
    let callCount = await counter.count
    #expect(callCount == 1)
}
```

## テストダブル（DI）

swift-dependencies を使うため、`withDependencies` でスタブを注入する。

### Domain 層（Actor のテスト）

```swift
try await withDependencies {
    $0.weatherAPIClient = TestWeatherAPIClient { _, _ in Weather.stub(temperature: 25.0) }
    $0.geocodingAPIClient = TestGeocodingAPIClient { _, _ in [] }
} operation: {
    let repo = WeatherRepository()
    let result = try await repo.fetchWeather(latitude: 35.68, longitude: 139.69)
    #expect(result.current.temperature == 25.0)
}
```

`TestWeatherAPIClient` / `TestGeocodingAPIClient` はクロージャでふるまいを注入し、テストケースごとに制御する。

### ViewModel 層（`@MainActor` のテスト）

ViewModel が `@MainActor` の場合、テスト struct にも `@MainActor` を付与する。
`withDependencies` でスタブを注入し、ViewModel を生成する。

```swift
@MainActor
struct CityListViewModelTests {
    private func makeFreshViewModel(
        repository: StubWeatherRepository = StubWeatherRepository(),
        cityListDefaults: UserDefaults = UserDefaults(suiteName: "test_\(UUID().uuidString)")!
    ) -> CityListViewModel {
        withDependencies {
            $0.weatherRepository = repository
            $0.cityListService = CityListService(defaults: cityListDefaults)
        } operation: {
            CityListViewModel()
        }
    }
}
```

ViewModel 内の非同期 `Task { }` はスタブが即時完了しても非同期で走るため、`Task.sleep` で待機する。

```swift
vm.loadAllWeather()
try await Task.sleep(for: .milliseconds(100))
#expect(vm.citiesWeather[1] != nil)
```

## フィクスチャ

モデルのデフォルト値は `static func stub(...)` ファクトリで定義する。

- **WeatherDomain テスト**：各テストファイル内に `private extension` で定義
- **WeatherFeature テスト**：`Stubs.swift` に共有 `extension` として定義済み

```swift
private extension Weather {
    static func stub(
        temperature: Double = 20.0,
        code: WeatherCode = .clearSky
    ) -> Weather {
        Weather(current: CurrentWeather(...), hourly: [], daily: [])
    }
}
```

## 永続化・副作用の分離

`UserDefaults` を使うテストは `suiteName` に `UUID` を用いて分離する。
永続化サービスはモックを使わず、UUID 隔離したリアル実装で検証する。

```swift
let defaults = try #require(UserDefaults(suiteName: "test_\(UUID().uuidString)"))
let service = CityListService(defaults: defaults)
service.save([city])
#expect(CityListService(defaults: defaults).load().count == 1)
```

## Package.swift 設定

- `swift test` をコマンドラインから実行する場合は `.macOS(.v14)` を `platforms` に追加する
- テストターゲットの依存は `dependencies` に明示する

```swift
.testTarget(
    name: "WeatherDomainTests",
    dependencies: ["WeatherDomain", "CoreNetwork", "CoreModels"]
)
```

## テスト実行

```bash
make test                # 全パッケージ
make test-models         # CoreModels のみ
make test-network        # CoreNetwork のみ
make test-domain         # WeatherDomain のみ
make test-feature-mvvm   # WeatherFeature MVVM のみ
make test-feature-tca    # WeatherFeature TCA のみ
make test-feature        # MVVM・TCA 両方
```

Xcode から実行する場合は `WeatherNow.xcworkspace` を開き、各パッケージのテストターゲットを選択して ⌘U で実行する。SPM パッケージのテストを WeatherNow アプリの TestPlan に含めることはできない。
