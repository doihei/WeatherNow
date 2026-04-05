import CoreModels
import CoreUI
import SwiftUI

// MARK: - SettingsView

public struct SettingsView: View {
    @Bindable var appViewModel: AppViewModel

    public init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }

    public var body: some View {
        List {
            Section(L10n.settingsUnitSection) {
                Picker(L10n.settingsTemperaturePicker, selection: $appViewModel.settings.temperatureUnit) {
                    ForEach(AppSettings.TemperatureUnit.allCases, id: \.self) { unit in
                        Text(unit.symbol).tag(unit)
                    }
                }
                Picker(L10n.settingsWindPicker, selection: $appViewModel.settings.windUnit) {
                    ForEach(AppSettings.WindUnit.allCases, id: \.self) { unit in
                        Text(unit.symbol).tag(unit)
                    }
                }
            }
            Section(L10n.settingsAppearanceSection) {
                Picker(L10n.settingsThemePicker, selection: $appViewModel.settings.theme) {
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
        .onChange(of: appViewModel.settings) {
            appViewModel.saveSettings()
        }
        .task {
            appViewModel.loadSettings()
        }
    }
}
