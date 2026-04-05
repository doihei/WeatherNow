import ComposableArchitecture
import CoreModels
import CoreUI
import SwiftUI

// MARK: - CitySearchView (TCA)

public struct CitySearchView: View {
    @Bindable var store: StoreOf<CitySearchFeature>

    public init(store: StoreOf<CitySearchFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            if store.isSearching {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if store.results.isEmpty, !store.query.isEmpty {
                Text(L10n.citySearchEmptyResult)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(store.results) { result in
                    CitySearchResultRow(
                        result: result,
                        isAdded: store.addedCityIDs.contains(result.id)
                    ) {
                        store.send(.addCityTapped(result))
                    }
                }
            }

            if let error = store.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .searchable(text: $store.query.sending(\.queryChanged), prompt: L10n.citySearchSearchPrompt)
        .navigationTitle(L10n.citySearchTitle)
    }
}

// MARK: - CitySearchResultRow

private struct CitySearchResultRow: View {
    let result: GeocodingResult
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(result.name)
                    .font(.body)
                Text(result.country)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isAdded {
                Image(systemName: AppSymbol.cityAdded.rawValue)
                    .foregroundStyle(.green)
            } else {
                Button {
                    onAdd()
                } label: {
                    Image(systemName: AppSymbol.addCityButton.rawValue)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, Spacing.xxSmall)
    }
}
