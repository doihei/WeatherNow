import CoreModels
import CoreNetwork
import Dependencies
import Foundation
import Testing
@testable import WeatherDomain

// MARK: - テスト用フィクスチャ

private extension Weather {
    static func stub(temperature: Double = 22.0) -> Weather {
        Weather(
            current: CurrentWeather(
                temperature: temperature,
                feelsLike: 20.0,
                humidity: 60,
                windSpeed: 12.0,
                code: .clearSky
            ),
            hourly: [],
            daily: []
        )
    }
}

// MARK: - WeatherRepositoryTests

struct WeatherRepositoryTests {
    // MARK: - fetchWeather

    @Test("fetchWeather が天気データを返す")
    func fetchWeatherReturnsData() async throws {
        let expected = Weather.stub(temperature: 25.0)
        try await withDependencies {
            $0.weatherAPIClient = TestWeatherAPIClient { _, _ in expected }
        } operation: {
            let repo = WeatherRepository()
            let result = try await repo.fetchWeather(latitude: 35.68, longitude: 139.69)
            #expect(result == expected)
        }
    }

    @Test("fetchWeather 2回目はキャッシュから返し API を呼ばない")
    func fetchWeatherUsesCache() async throws {
        actor CallCounter { var count = 0
            func increment() {
                count += 1
            }
        }
        let counter = CallCounter()

        try await withDependencies {
            $0.weatherAPIClient = TestWeatherAPIClient { _, _ in
                await counter.increment()
                return .stub()
            }
        } operation: {
            let repo = WeatherRepository()
            _ = try await repo.fetchWeather(latitude: 35.68, longitude: 139.69)
            _ = try await repo.fetchWeather(latitude: 35.68, longitude: 139.69)
            #expect(await counter.count == 1)
        }
    }

    @Test("キャッシュキーは小数点2桁精度で正規化される（近傍座標はキャッシュヒット）")
    func fetchWeatherCacheKeyNormalization() async throws {
        actor CallCounter { var count = 0
            func increment() {
                count += 1
            }
        }
        let counter = CallCounter()

        try await withDependencies {
            $0.weatherAPIClient = TestWeatherAPIClient { _, _ in
                await counter.increment()
                return .stub()
            }
        } operation: {
            let repo = WeatherRepository()
            // 差が0.004度 ≈ 400m → 丸め後に同一キー
            _ = try await repo.fetchWeather(latitude: 35.6762, longitude: 139.6503)
            _ = try await repo.fetchWeather(latitude: 35.6764, longitude: 139.6504)
            #expect(await counter.count == 1)
        }
    }

    @Test("clearCache 後は API を再呼び出しする")
    func clearCacheForcesFetch() async throws {
        actor CallCounter { var count = 0
            func increment() {
                count += 1
            }
        }
        let counter = CallCounter()

        try await withDependencies {
            $0.weatherAPIClient = TestWeatherAPIClient { _, _ in
                await counter.increment()
                return .stub()
            }
        } operation: {
            let repo = WeatherRepository()
            _ = try await repo.fetchWeather(latitude: 35.68, longitude: 139.69)
            await repo.clearCache()
            _ = try await repo.fetchWeather(latitude: 35.68, longitude: 139.69)
            #expect(await counter.count == 2)
        }
    }

    @Test("WeatherError はそのまま再スローされる")
    func weatherErrorPropagatesDirectly() async throws {
        try await withDependencies {
            $0.weatherAPIClient = TestWeatherAPIClient { _, _ in throw WeatherError.decodingFailure }
        } operation: {
            let repo = WeatherRepository()
            do {
                _ = try await repo.fetchWeather(latitude: 0, longitude: 0)
                Issue.record("エラーがスローされるはず")
            } catch {
                #expect(error as? WeatherError == .decodingFailure)
            }
        }
    }

    @Test("WeatherError 以外は networkFailure にラップされる")
    func genericErrorWrappedAsNetworkFailure() async throws {
        try await withDependencies {
            $0.weatherAPIClient = TestWeatherAPIClient { _, _ in throw URLError(.timedOut) }
        } operation: {
            let repo = WeatherRepository()
            do {
                _ = try await repo.fetchWeather(latitude: 0, longitude: 0)
                Issue.record("エラーがスローされるはず")
            } catch let error as WeatherError {
                if case .networkFailure = error { /* expected */ } else {
                    Issue.record("networkFailure を期待したが: \(error)")
                }
            } catch {
                Issue.record("WeatherError を期待したが: \(error)")
            }
        }
    }

    // MARK: - searchCities

    @Test("searchCities が検索結果を返す")
    func searchCitiesReturnsResults() async throws {
        let expected = [
            GeocodingResult(id: 1, name: "東京", country: "日本", latitude: 35.68, longitude: 139.69),
        ]
        try await withDependencies {
            $0.geocodingAPIClient = TestGeocodingAPIClient { _, _ in expected }
        } operation: {
            let repo = WeatherRepository()
            let results = try await repo.searchCities(name: "東京")
            #expect(results == expected)
        }
    }

    @Test("searchCities の WeatherError はそのまま再スローされる")
    func searchCitiesWeatherErrorPropagates() async throws {
        try await withDependencies {
            $0.geocodingAPIClient = TestGeocodingAPIClient { _, _ in throw WeatherError.cityLimitReached }
        } operation: {
            let repo = WeatherRepository()
            do {
                _ = try await repo.searchCities(name: "test")
                Issue.record("エラーがスローされるはず")
            } catch {
                #expect(error as? WeatherError == .cityLimitReached)
            }
        }
    }

    @Test("searchCities の一般エラーは networkFailure にラップされる")
    func searchCitiesGenericErrorWrapped() async throws {
        try await withDependencies {
            $0.geocodingAPIClient = TestGeocodingAPIClient { _, _ in throw URLError(.notConnectedToInternet) }
        } operation: {
            let repo = WeatherRepository()
            do {
                _ = try await repo.searchCities(name: "test")
                Issue.record("エラーがスローされるはず")
            } catch let error as WeatherError {
                if case .networkFailure = error { /* expected */ } else {
                    Issue.record("networkFailure を期待したが: \(error)")
                }
            } catch {
                Issue.record("WeatherError を期待したが: \(error)")
            }
        }
    }
}
