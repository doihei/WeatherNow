import ComposableArchitecture
import CoreModels
import CoreUI
import SwiftUI

// MARK: - CityListView (TCA)

public struct CityListView: View {
    @Bindable var store: StoreOf<CityListFeature>
    let temperatureUnit: AppSettings.TemperatureUnit

    public init(store: StoreOf<CityListFeature>, temperatureUnit: AppSettings.TemperatureUnit) {
        self.store = store
        self.temperatureUnit = temperatureUnit
    }

    public var body: some View {
        List {
            ForEach(store.scope(state: \.rows, action: \.rows)) { rowStore in
                CityRowView(store: rowStore, temperatureUnit: temperatureUnit)
            }
            .onDelete { store.send(.removeCity($0)) }
            .onMove { store.send(.moveCity($0, $1)) }
        }
        .navigationTitle(L10n.cityListTitle)
        .toolbar {
            #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.send(.showCitySearch)
                    } label: {
                        Image(systemName: AppSymbol.addCity.rawValue)
                    }
                }
            #endif
        }
        .refreshable {
            store.send(.refresh)
        }
        .overlay {
            if let error = store.errorMessage {
                VStack {
                    Spacer()
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(Spacing.medium)
                        .background(Color.red.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: Size.CornerRadius.small))
                        .padding()
                }
            }
        }
        .task {
            store.send(.onAppear)
        }
    }
}
