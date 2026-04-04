import ComposableArchitecture
import CoreLocation
import CoreModels
import WeatherDomain

// MARK: - CurrentWeatherFeature

@Reducer
public struct CurrentWeatherFeature: Sendable {

    // MARK: - ViewState

    public enum ViewState: Sendable, Equatable {
        case idle
        case loading
        case loaded(Weather)
        case error(WeatherError)
    }

    // MARK: - State

    @ObservableState
    public struct State: Sendable, Equatable {
        public var viewState: ViewState = .idle
        public var cityName: String = ""

        public init() {}
    }

    // MARK: - Action

    public enum Action: Sendable, Equatable {
        /// View の .task から呼ぶ。viewState == .idle の場合のみロードを開始する。
        case onAppear
        /// Pull-to-Refresh。キャッシュクリア後に再ロードする。
        case refresh
        case cityNameResolved(String)
        case weatherResponse(Result<Weather, WeatherError>)
    }

    // MARK: - CancelID

    private enum CancelID: Hashable {
        case load
    }

    // MARK: - Dependencies

    @Dependency(\.weatherRepository) var repository
    @Dependency(\.locationService) var locationService

    // MARK: - Reducer

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.viewState == .idle else { return .none }
                state.viewState = .loading
                return fetchEffect()

            case .refresh:
                // viewState を idle に戻してから clearCache → onAppear を送信
                state.viewState = .idle
                return .run { [repository] send in
                    await repository.clearCache()
                    await send(.onAppear)
                }
                .cancellable(id: CancelID.load, cancelInFlight: true)

            case let .cityNameResolved(name):
                state.cityName = name
                return .none

            case let .weatherResponse(.success(weather)):
                state.viewState = .loaded(weather)
                return .none

            case let .weatherResponse(.failure(error)):
                state.viewState = .error(error)
                return .none
            }
        }
    }

    // MARK: - Private

    private func fetchEffect() -> Effect<Action> {
        .run { [locationService, repository] send in
            do {
                let location = try await locationService.requestCurrentLocation()

                // 逆ジオコーディング（失敗しても天気取得は継続）
                let geocoder = CLGeocoder()
                let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                if let placemarks = try? await geocoder.reverseGeocodeLocation(clLocation),
                   let placemark = placemarks.first
                {
                    let name = placemark.locality ?? placemark.administrativeArea ?? ""
                    if !name.isEmpty { await send(.cityNameResolved(name)) }
                }

                let weather = try await repository.fetchWeather(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
                await send(.weatherResponse(.success(weather)))
            } catch let error as WeatherError {
                await send(.weatherResponse(.failure(error)))
            } catch {
                await send(.weatherResponse(.failure(.networkFailure(error.localizedDescription))))
            }
        }
        .cancellable(id: CancelID.load, cancelInFlight: true)
    }
}
