import CoreModels
import SFSafeSymbols
import SwiftUI

// MARK: - WeatherIconView

/// WeatherCode を SF Symbol で表示する共通コンポーネント。
public struct WeatherIconView: View {
    let code: WeatherCode
    var size: CGFloat

    public init(code: WeatherCode, size: CGFloat = Size.iconMD) {
        self.code = code
        self.size = size
    }

    public var body: some View {
        Image(systemSymbol: code.symbol)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
