import CoreModels
import CoreUI
import SwiftUI

// MARK: - CityListView

public struct CityListView: View {
    @State var viewModel: CityListViewModel
    @Binding var cityPath: NavigationPath
    let settings: AppSettings
    let makeCitySearchViewModel: () -> CitySearchViewModel

    public init(
        viewModel: CityListViewModel,
        cityPath: Binding<NavigationPath>,
        settings: AppSettings,
        makeCitySearchViewModel: @escaping () -> CitySearchViewModel
    ) {
        self.viewModel = viewModel
        self._cityPath = cityPath
        self.settings = settings
        self.makeCitySearchViewModel = makeCitySearchViewModel
    }

    public var body: some View {
        List {
            ForEach(viewModel.cities) { city in
                CityRow(
                    city: city,
                    weather: viewModel.citiesWeather[city.id],
                    temperatureUnit: settings.temperatureUnit
                )
            }
            .onDelete { viewModel.remove(at: $0) }
            .onMove { viewModel.move(from: $0, to: $1) }
        }
        .navigationTitle(L10n.cityListTitle)
        .toolbar {
            #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        cityPath.append(CityDestination.search)
                    } label: {
                        Image(systemName: AppSymbol.addCity.rawValue)
                    }
                }
            #endif
        }
        .refreshable {
            viewModel.loadAllWeather()
        }
        .overlay {
            if let error = viewModel.errorMessage {
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
            viewModel.loadCities()
            viewModel.loadAllWeather()
        }
        .navigationDestination(for: CityDestination.self) { _ in
            CitySearchView(viewModel: makeCitySearchViewModel())
        }
    }
}

// MARK: - CityRow

private struct CityRow: View {
    let city: City
    let weather: Weather?
    let temperatureUnit: AppSettings.TemperatureUnit

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                Text(city.name)
                    .font(.headline)
                Text(city.country)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let weather {
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
    }
}
