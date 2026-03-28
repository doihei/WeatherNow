import CoreModels
import Observation
import WeatherDomain

// MARK: - CitySearchViewModel

@MainActor
@Observable
public final class CitySearchViewModel {
    // MARK: - State

    public private(set) var query: String = ""
    public private(set) var results: [GeocodingResult] = []
    public private(set) var isSearching: Bool = false
    public private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let repository: any WeatherRepositoryProtocol
    private let cityListViewModel: CityListViewModel

    // MARK: - Task Management

    private enum TaskKey: Hashable {
        case search
    }

    private var tasks: [TaskKey: Task<Void, Never>] = [:]

    // MARK: - Init

    public init(
        repository: any WeatherRepositoryProtocol,
        cityListViewModel: CityListViewModel
    ) {
        self.repository = repository
        self.cityListViewModel = cityListViewModel
    }

    // MARK: - Actions

    /// クエリを更新し、300ms debounce 後に検索を実行する。
    public func updateQuery(_ newQuery: String) {
        query = newQuery
        errorMessage = nil
        tasks[.search]?.cancel()

        guard !newQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }

        tasks[.search] = Task {
            do {
                // 300ms debounce
                try await Task.sleep(for: .milliseconds(300))
                try Task.checkCancellation()

                isSearching = true
                let searchResults = try await repository.searchCities(name: newQuery)
                guard !Task.isCancelled else { return }
                results = searchResults
            } catch is CancellationError {
                // Debounce による通常キャンセル
            } catch let error as WeatherError {
                guard !Task.isCancelled else { return }
                errorMessage = error.userMessage
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
            }
            isSearching = false
        }
    }

    /// 都市を CityListViewModel に追加する。
    public func addCity(_ result: GeocodingResult) {
        cityListViewModel.add(result)
    }

    /// すでに登録済みかどうかを返す。
    public func isCityAdded(_ result: GeocodingResult) -> Bool {
        cityListViewModel.isCityAdded(result)
    }
}
