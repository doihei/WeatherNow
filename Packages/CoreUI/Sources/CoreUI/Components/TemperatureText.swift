import CoreModels
import SwiftUI

// MARK: - TemperatureText

/// 摂氏値を設定された単位に変換して表示する共通コンポーネント。
public struct TemperatureText: View {
    let celsius: Double
    let unit: AppSettings.TemperatureUnit

    public init(celsius: Double, unit: AppSettings.TemperatureUnit) {
        self.celsius = celsius
        self.unit = unit
    }

    public var body: some View {
        Text(formatted)
    }

    private var formatted: String {
        let value = unit.convert(celsius)
        return String(format: "%.0f%@", value, unit.symbol)
    }
}
