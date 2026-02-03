import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(SettingsKeys.theme) private var themeRaw = Theme.system.rawValue
    @AppStorage(SettingsKeys.showSeconds) private var showSeconds = false
    @AppStorage(SettingsKeys.backgroundColor) private var backgroundColorData = Preferences.defaultBackgroundData
    @AppStorage(SettingsKeys.flapColor) private var flapColorData = Preferences.defaultFlapData
    @AppStorage(SettingsKeys.textColor) private var textColorData = Preferences.defaultTextData
    @AppStorage(SettingsKeys.font) private var fontData = Preferences.defaultFontData
    @AppStorage(SettingsKeys.fontScale) private var fontScale = Preferences.defaultFontScale
    @AppStorage(SettingsKeys.flapScale) private var flapScale = Preferences.defaultFlapScale
    @AppStorage(SettingsKeys.flapCornerScale) private var flapCornerScale = Preferences.defaultFlapCornerScale

    private var theme: Theme {
        Theme(rawValue: themeRaw) ?? .system
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $themeRaw) {
                        ForEach(Theme.allCases) { theme in
                            Text(theme.title).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: themeRaw) { newValue in
                        if Theme(rawValue: newValue) != .custom {
                            resetCustomColors()
                        }
                    }

                    if theme == .custom {
                        ColorPicker("Background Color", selection: backgroundColorBinding)
                        ColorPicker("Flap Color", selection: flapColorBinding)
                        ColorPicker("Text Color", selection: textColorBinding)
                    }

                    NavigationLink {
                        FontPickerView(fontData: $fontData)
                    } label: {
                        HStack {
                            Text("Font")
                            Spacer()
                            Text(FontArchive.fontFamily(from: fontData))
                                .foregroundStyle(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Font Size")
                            Spacer()
                            Text("\(Int(fontScale * 100))%")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $fontScale, in: 0.1...4.0, step: 0.05)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Flap Size")
                            Spacer()
                            Text("\(Int(flapScale * 100))%")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $flapScale, in: 0.1...4.0, step: 0.05)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Corner Radius")
                            Spacer()
                            Text("\(Int(flapCornerScale * 100))%")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $flapCornerScale, in: 0.1...4.0, step: 0.05)
                    }

                    Button("Reset to Default", role: .destructive) {
                        resetDefaults()
                    }
                }

                Section {
                    Toggle("Show seconds", isOn: $showSeconds)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }

    private var backgroundColorBinding: Binding<Color> {
        Binding(
            get: {
                ColorArchive.color(from: backgroundColorData, fallback: Preferences.defaultBackground)
            },
            set: { newValue in
                backgroundColorData = ColorArchive.data(from: newValue)
            }
        )
    }

    private var flapColorBinding: Binding<Color> {
        Binding(
            get: {
                ColorArchive.color(from: flapColorData, fallback: Preferences.defaultFlap)
            },
            set: { newValue in
                flapColorData = ColorArchive.data(from: newValue)
            }
        )
    }

    private var textColorBinding: Binding<Color> {
        Binding(
            get: {
                ColorArchive.color(from: textColorData, fallback: Preferences.defaultText)
            },
            set: { newValue in
                textColorData = ColorArchive.data(from: newValue)
            }
        )
    }

    private func resetDefaults() {
        themeRaw = Theme.system.rawValue
        resetCustomColors()
        fontData = Preferences.defaultFontData
        fontScale = Preferences.defaultFontScale
        flapScale = Preferences.defaultFlapScale
        flapCornerScale = Preferences.defaultFlapCornerScale
    }

    private func resetCustomColors() {
        backgroundColorData = Preferences.defaultBackgroundData
        flapColorData = Preferences.defaultFlapData
        textColorData = Preferences.defaultTextData
    }
}
