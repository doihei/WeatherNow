import CoreModels
import Foundation
import Observation
import WeatherDomain

// MARK: - CityListViewModel

@MainActor
@Observable
public final class CityListViewModel {
    // MARK: - State

    public private(set) var cities: [City] = []
    public private(set) var citiesWeather: [Int: Weather] = [:]
    public private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let repository: any WeatherRepositoryProtocol

    // MARK: - Task Management

    private enum TaskKey: Hashable {
        case loadWeather
    }

    private var tasks: [TaskKey: Task<Void, Never>] = [:]

    // MARK: - Persistence

    private static let citiesKey = "registeredCities"

    // MARK: - Init

    public init(repository: any WeatherRepositoryProtocol) {
        self.repository = repository
        loadPersistedCities()
    }

    // MARK: - City Management

    /// 都市を登録する（上限10件・重複チェックあり）。
    public func add(_ result: GeocodingResult) {
        guard cities.count < 10 else {
            errorMessage = WeatherError.cityLimitReached.userMessage
            return
        }
        let city = result.toCity()
        guard !cities.contains(where: { $0.id == city.id }) else { return }
        cities.append(city)
        persistCities()
    }

    /// 都市を削除する。
    public func remove(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
        persistCities()
    }

    /// 都市の並び順を変更する。
    public func move(from source: IndexSet, to destination: Int) {
        cities.move(fromOffsets: source, toOffset: destination)
        persistCities()
    }

    /// 検索結果がすでに登録済みかどうかを返す。
    public func isCityAdded(_ result: GeocodingResult) -> Bool {
        cities.contains(where: { $0.id == result.id })
    }

    // MARK: - Weather Loading

    /// 全登録都市の天気を一括取得する。
    public func loadAllWeather() {
        tasks[.loadWeather]?.cancel()
        tasks[.loadWeather] = Task {
            for city in cities {
                guard !Task.isCancelled else { return }
                if let weather = try? await repository.fetchWeather(
                    latitude: city.latitude,
                    longitude: city.longitude
                ) {
                    citiesWeather[city.id] = weather
                }
            }
        }
    }

    // MARK: - Persistence

    private func loadPersistedCities() {
        guard
            let data = UserDefaults.standard.data(forKey: Self.citiesKey),
            let decoded = try? JSONDecoder().decode([City].self, from: data)
        else { return }
        cities = decoded
    }

    private func persistCities() {
        guard let data = try? JSONEncoder().encode(cities) else { return }
        UserDefaults.standard.set(data, forKey: Self.citiesKey)
    }
}
