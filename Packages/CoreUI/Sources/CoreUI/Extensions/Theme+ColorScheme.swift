import CoreModels
import SwiftUI

// MARK: - AppSettings.Theme + ColorScheme

public extension AppSettings.Theme {
    /// SwiftUI の `preferredColorScheme` に渡す値に変換する。
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
