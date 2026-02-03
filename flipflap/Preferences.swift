import SwiftUI
import UIKit

enum SettingsKeys {
    static let theme = "theme"
    static let showSeconds = "showSeconds"
    static let backgroundColor = "background_color"
    static let flapColor = "flap_color"
    static let textColor = "text_color"
    static let font = "font"
    static let fontScale = "font_scale"
    static let flapScale = "flap_scale"
    static let flapCornerScale = "flap_corner_scale"
    static let flapSoundMode = "flap_sound_mode"
    static let flapSoundSystemID = "flap_sound_system_id"
    static let flapSoundCustomName = "flap_sound_custom_name"
    static let flapSoundBundledName = "flap_sound_bundled_name"
}

enum Theme: Int, CaseIterable, Identifiable {
    case system = 0
    case light = 1
    case dark = 2
    case custom = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .custom:
            return "Custom"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system, .custom:
            return nil
        }
    }
}

enum Preferences {
    static let defaultBackground = UIColor.systemBackground
    static let defaultFlap = UIColor.secondarySystemBackground
    static let defaultText = UIColor.label
    static let defaultFontFamily = "Courier"
    static let defaultFontSize: CGFloat = 45.0
    static let defaultFontScale = 1.0
    static let defaultFlapScale = 1.0
    static let defaultFlapCornerScale = 1.0
    static let defaultBackgroundData = ColorArchive.encode(defaultBackground)
    static let defaultFlapData = ColorArchive.encode(defaultFlap)
    static let defaultTextData = ColorArchive.encode(defaultText)
    static let defaultFontData = FontArchive.encode(fontFamily: defaultFontFamily, size: defaultFontSize)
}

enum ColorArchive {
    static func encode(_ color: UIColor) -> Data {
        (try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)) ?? Data()
    }

    static func decode(_ data: Data?, fallback: UIColor) -> UIColor {
        guard let data, let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
            return fallback
        }
        return color
    }

    static func color(from data: Data?, fallback: UIColor) -> Color {
        Color(decode(data, fallback: fallback))
    }

    static func data(from color: Color) -> Data {
        encode(UIColor(color))
    }
}

enum FontArchive {
    static func encode(fontFamily: String, size: CGFloat) -> Data {
        let font = UIFont(name: fontFamily, size: size)
            ?? UIFont(name: Preferences.defaultFontFamily, size: size)
            ?? UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
        return (try? NSKeyedArchiver.archivedData(withRootObject: font, requiringSecureCoding: false)) ?? Data()
    }

    static func decodeFont(from data: Data?) -> UIFont? {
        guard let data else {
            return nil
        }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIFont.self, from: data)
    }

    static func fontFamily(from data: Data?) -> String {
        if let font = decodeFont(from: data) {
            return font.familyName
        }
        return Preferences.defaultFontFamily
    }

    static func font(from data: Data?, size: CGFloat) -> Font {
        if let storedFont = decodeFont(from: data), let uiFont = UIFont(name: storedFont.familyName, size: size) {
            return Font(uiFont)
        }
        if let courier = UIFont(name: Preferences.defaultFontFamily, size: size) {
            return Font(courier)
        }
        return Font.system(size: size, weight: .regular, design: .monospaced)
    }
}
