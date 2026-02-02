import SwiftUI
import UniformTypeIdentifiers

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
    @AppStorage(SettingsKeys.flapSoundMode) private var flapSoundModeRaw = FlapSoundMode.none.rawValue
    @AppStorage(SettingsKeys.flapSoundSystemID) private var flapSoundSystemID = FlapSoundDefaults.defaultSystemSoundID
    @AppStorage(SettingsKeys.flapSoundCustomName) private var flapSoundCustomName = ""
    @AppStorage(SettingsKeys.flapSoundBundledName) private var flapSoundBundledName = FlapSoundDefaults.defaultBundledSoundName

    @State private var isImportingCustomSound = false
    @State private var importErrorMessage = ""
    @State private var showImportError = false

    private var theme: Theme {
        Theme(rawValue: themeRaw) ?? .system
    }

    private var flapSoundMode: FlapSoundMode {
        FlapSoundMode(rawValue: flapSoundModeRaw) ?? .none
    }

    private var systemSoundOptions: [SystemSoundOption] {
        var options = FlapSoundDefaults.systemSoundOptions
        if options.contains(where: { $0.id == flapSoundSystemID }) == false {
            options.append(SystemSoundOption(id: flapSoundSystemID, name: "Sound \(flapSoundSystemID)"))
        }
        return options
    }

    private var bundledSoundOptions: [BundledSoundOption] {
        var options = FlapSoundDefaults.bundledOptions
        if options.contains(where: { $0.id == flapSoundBundledName }) == false {
            options.append(
                BundledSoundOption(
                    id: flapSoundBundledName,
                    name: "Sound \(flapSoundBundledName)",
                    fileName: flapSoundBundledName,
                    fileExtension: "wav"
                )
            )
        }
        return options
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
                        Slider(value: $fontScale, in: 0.5...4.0, step: 0.05)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Flap Size")
                            Spacer()
                            Text("\(Int(flapScale * 100))%")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $flapScale, in: 0.5...4.0, step: 0.05)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Corner Radius")
                            Spacer()
                            Text("\(Int(flapCornerScale * 100))%")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $flapCornerScale, in: 0.5...4.0, step: 0.05)
                    }

                    Button("Reset to Default", role: .destructive) {
                        resetDefaults()
                    }
                }

                Section {
                    Toggle("Show seconds", isOn: $showSeconds)
                }

                Section("Sound") {
                    Picker("Flap Sound", selection: $flapSoundModeRaw) {
                        ForEach(FlapSoundMode.allCases) { mode in
                            Text(mode.title).tag(mode.rawValue)
                        }
                    }

                    switch flapSoundMode {
                    case .none:
                        EmptyView()
                    case .bundled:
                        Picker("Flap Sample", selection: $flapSoundBundledName) {
                            ForEach(bundledSoundOptions) { option in
                                Text(option.name).tag(option.id)
                            }
                        }

                        Text(bundledSoundStatus)
                            .foregroundStyle(.secondary)
                    case .system:
                        Picker("System Sound", selection: $flapSoundSystemID) {
                            ForEach(systemSoundOptions) { option in
                                Text(option.name).tag(option.id)
                            }
                        }
                    case .custom:
                        VStack(alignment: .leading, spacing: 8) {
                            Text(customSoundStatus)
                                .foregroundStyle(.secondary)

                            Button("Choose Sound") {
                                isImportingCustomSound = true
                            }

                            if !flapSoundCustomName.isEmpty {
                                Button("Clear Custom Sound", role: .destructive) {
                                    flapSoundCustomName = ""
                                }
                            }
                        }
                    }
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
        .onAppear {
            clampScales()
        }
        .fileImporter(
            isPresented: $isImportingCustomSound,
            allowedContentTypes: soundContentTypes
        ) { result in
            switch result {
            case .success(let url):
                if let fileName = FlapSoundStorage.importSound(from: url) {
                    flapSoundCustomName = fileName
                    flapSoundModeRaw = FlapSoundMode.custom.rawValue
                } else {
                    importErrorMessage = "Unable to import that audio file."
                    showImportError = true
                }
            case .failure:
                importErrorMessage = "Unable to import that audio file."
                showImportError = true
            }
        }
        .alert("Sound Import Failed", isPresented: $showImportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(importErrorMessage)
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

    private var soundContentTypes: [UTType] {
        var types: [UTType] = [.audio]
        for ext in ["wav", "m4a", "mp3", "aif", "aiff", "caf"] {
            if let type = UTType(filenameExtension: ext) {
                types.append(type)
            }
        }
        return types
    }

    private var customSoundStatus: String {
        if flapSoundCustomName.isEmpty {
            return "No custom sound selected."
        }
        return "Custom sound: \(flapSoundCustomName)"
    }

    private var bundledSoundStatus: String {
        if FlapSoundPlayer.shared.hasBundledSound(named: flapSoundBundledName) {
            if let option = FlapSoundDefaults.bundledOptions.first(where: { $0.id == flapSoundBundledName }) {
                return "Using \(option.name)."
            }
            return "Using bundled flap sample."
        }
        return "Bundled flap sample is missing."
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

    private func clampScales() {
        fontScale = max(fontScale, 0.5)
        flapScale = max(flapScale, 0.5)
        flapCornerScale = max(flapCornerScale, 0.5)
    }
}
