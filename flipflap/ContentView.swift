import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage(SettingsKeys.showSeconds) private var showSeconds = false
    @AppStorage(SettingsKeys.theme) private var themeRaw = Theme.system.rawValue
    @AppStorage(SettingsKeys.backgroundColor) private var backgroundColorData = Preferences.defaultBackgroundData
    @AppStorage(SettingsKeys.flapColor) private var flapColorData = Preferences.defaultFlapData
    @AppStorage(SettingsKeys.textColor) private var textColorData = Preferences.defaultTextData
    @AppStorage(SettingsKeys.font) private var fontData = Preferences.defaultFontData

    @State private var showSettings = false
    @State private var settingsOpacity = 0.0
    @State private var hideTimer: Timer? = nil

    private var theme: Theme {
        Theme(rawValue: themeRaw) ?? .system
    }

    private var backgroundColor: Color {
        if theme == .custom {
            return ColorArchive.color(from: backgroundColorData, fallback: Preferences.defaultBackground)
        }
        return Color(Preferences.defaultBackground)
    }

    private var flapColor: Color {
        if theme == .custom {
            return ColorArchive.color(from: flapColorData, fallback: Preferences.defaultFlap)
        }
        return Color(Preferences.defaultFlap)
    }

    private var textColor: Color {
        if theme == .custom {
            return ColorArchive.color(from: textColorData, fallback: Preferences.defaultText)
        }
        return Color(Preferences.defaultText)
    }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                SplitFlapView(
                    text: TimeFormatter.string(for: context.date, showSeconds: showSeconds),
                    flapColor: flapColor,
                    textColor: textColor,
                    fontData: fontData
                )
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Button {
                showSettings = true
            } label: {
                Label("Settings", systemImage: "gear")
                    .font(.system(size: 20, weight: .semibold))
            }
            .foregroundStyle(.tint)
            .labelStyle(.iconOnly)
            .buttonBorderShape(.circle)
            .buttonStyle(.glass)
            .opacity(settingsOpacity)
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .statusBarHidden(true)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            revealSettingsButton()
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                revealSettingsButton()
            }
        )
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private func revealSettingsButton() {
        hideTimer?.invalidate()
        hideTimer = nil
        withAnimation(.easeInOut(duration: 0.5)) {
            settingsOpacity = 1.0
        } completion: {
            hideTimer?.invalidate()
            hideTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                withAnimation(.easeInOut(duration: 2.0)) {
                    settingsOpacity = .zero
                }
            }
        }
    }
}
