import CoreLocation
import CoreModels
import Dependencies
import Observation
import WeatherDomain

// MARK: - CurrentWeatherViewModel

@MainActor
@Observable
public final class CurrentWeatherViewModel {
    // MARK: - ViewState

    public enum ViewState {
        case idle
        case loading
        case loaded(Weather)
        case error(WeatherError)
    }

    // MARK: - State

    public private(set) var state: ViewState = .idle
    public private(set) var cityName: String = ""

    // MARK: - Dependencies

    @ObservationIgnored
    @Dependency(\.weatherRepository) private var repository

    @ObservationIgnored
    @Dependency(\.locationService) private var locationService

    // MARK: - Task Management

    private enum TaskKey: Hashable {
        case load
    }

    private var tasks: [TaskKey: Task<Void, Never>] = [:]

    // MARK: - Init

    public init() {}

    // MARK: - Actions

    public func load() {
        tasks[.load]?.cancel()
        tasks[.load] = Task {
            state = .loading
            do {
                let location = try await locationService.requestCurrentLocation()

                // 逆ジオコーディングで市区町村名を取得
                await resolveLocationName(
                    latitude: location.latitude,
                    longitude: location.longitude
                )

                let weather = try await repository.fetchWeather(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
                guard !Task.isCancelled else { return }
                state = .loaded(weather)
            } catch let error as WeatherError {
                guard !Task.isCancelled else { return }
                state = .error(error)
            } catch {
                guard !Task.isCancelled else { return }
                state = .error(.networkFailure(error.localizedDescription))
            }
        }
    }

    public func refresh() {
        tasks[.load]?.cancel()
        tasks[.load] = Task {
            await repository.clearCache()
            load()
        }
    }

    // MARK: - Private

    private func resolveLocationName(latitude: Double, longitude: Double) async {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: latitude, longitude: longitude)
        guard let placemarks = try? await geocoder.reverseGeocodeLocation(clLocation),
              let placemark = placemarks.first
        else { return }
        cityName = placemark.locality ?? placemark.administrativeArea ?? ""
    }
}
