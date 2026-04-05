import Foundation

public enum Size {
    // Icon sizes
    public static let iconXS: CGFloat = 20
    public static let iconSM: CGFloat = 24
    public static let iconMD: CGFloat = 40
    public static let iconLG: CGFloat = 64

    /// Font sizes
    public static let fontDisplay: CGFloat = 64

    // Component dimensions
    public static let touchTarget: CGFloat = 48
    public static let labelColumn: CGFloat = 72

    /// Chart heights
    public static let chartDefault: CGFloat = 200

    // MARK: - CornerRadius

    public enum CornerRadius {
        public static let xSmall: CGFloat = 4
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 16
    }
}
