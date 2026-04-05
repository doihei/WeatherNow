import Foundation

// MARK: - LocalizedStringResource

public extension LocalizedStringResource {
    func string(options: String.LocalizationOptions? = nil) -> String {
        guard let options else {
            return String(localized: self)
        }
        return String(localized: self, options: options)
    }
}
