import ComposableArchitecture
import CoreModels
import CoreUI
import SwiftUI

// MARK: - SettingsView (TCA)

public struct SettingsView: View {
    let store: StoreOf<RootFeature>
    @State private var localSettings: AppSettings = .default

    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            Section(L10n.settingsUnitSection) {
                Picker(L10n.settingsTemperaturePicker, selection: $localSettings.temperatureUnit) {
                    ForEach(AppSettings.TemperatureUnit.allCases, id: \.self) { unit in
                        Text(unit.symbol).tag(unit)
                    }
                }
                Picker(L10n.settingsWindPicker, selection: $localSettings.windUnit) {
                    ForEach(AppSettings.WindUnit.allCases, id: \.self) { unit in
                        Text(unit.symbol).tag(unit)
                    }
                }
            }
            Section(L10n.settingsAppearanceSection) {
                Picker(L10n.settingsThemePicker, selection: $localSettings.theme) {
                    ForEach(AppSettings.Theme.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
            }
            Section(L10n.settingsInfoSection) {
                LabeledContent("API", value: "Open-Meteo v1")
            }
        }
        .navigationTitle(L10n.settingsTitle)
        .onAppear {
            localSettings = store.settings
        }
        .onChange(of: localSettings) { _, newSettings in
            store.send(.settingsChanged(newSettings))
        }
        .task {
            store.send(.onAppear)
        }
    }
}
