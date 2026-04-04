import ComposableArchitecture
import CoreModels
import WeatherDomain

// MARK: - CityRowFeature

@Reducer
public struct CityRowFeature: Sendable {

    // MARK: - State

    @ObservableState
    public struct State: Sendable, Equatable, Identifiable {
        public let city: City
        public var weather: Weather?

        public var id: Int { city.id }

        public init(city: City, weather: Weather? = nil) {
            self.city = city
            self.weather = weather
        }
    }

    // MARK: - Action

    public enum Action: Sendable, Equatable {
        case onAppear
        case weatherResponse(Result<Weather, WeatherError>)
    }

    // MARK: - CancelID

    private enum CancelID: Hashable {
        case fetchWeather(Int)
    }

    // MARK: - Dependencies

    @Dependency(\.weatherRepository) var repository

    // MARK: - Reducer

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.weather == nil else { return .none }
                let city = state.city
                return .run { send in
                    do {
                        let weather = try await repository.fetchWeather(
                            latitude: city.latitude,
                            longitude: city.longitude
                        )
                        await send(.weatherResponse(.success(weather)))
                    } catch let error as WeatherError {
                        await send(.weatherResponse(.failure(error)))
                    } catch {
                        await send(.weatherResponse(.failure(.networkFailure(error.localizedDescription))))
                    }
                }
                .cancellable(id: CancelID.fetchWeather(state.city.id), cancelInFlight: true)

            case let .weatherResponse(.success(weather)):
                state.weather = weather
                return .none

            case .weatherResponse(.failure):
                // 行レベルのエラーは握りつぶし（親 Feature には伝播しない）
                return .none
            }
        }
    }
}
