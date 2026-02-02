import SwiftUI

@main
struct FlipflapApp: App {
    @AppStorage(SettingsKeys.theme) private var themeRaw = Theme.system.rawValue

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(Theme(rawValue: themeRaw)?.colorScheme)
        }
    }
}
