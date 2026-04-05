import ComposableArchitecture
import CoreModels
import CoreUI
import SwiftUI

// MARK: - CityRowView

public struct CityRowView: View {
    let store: StoreOf<CityRowFeature>
    let temperatureUnit: AppSettings.TemperatureUnit

    public init(store: StoreOf<CityRowFeature>, temperatureUnit: AppSettings.TemperatureUnit) {
        self.store = store
        self.temperatureUnit = temperatureUnit
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                Text(store.city.name)
                    .font(.headline)
                Text(store.city.country)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let weather = store.weather {
                HStack(spacing: Spacing.medium) {
                    WeatherIconView(code: weather.current.code, size: Size.iconSM)
                    TemperatureText(celsius: weather.current.temperature, unit: temperatureUnit)
                        .font(.title3)
                }
            } else {
                ProgressView()
            }
        }
        .padding(.vertical, Spacing.xSmall)
        .onAppear { store.send(.onAppear) }
    }
}
