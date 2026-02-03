import AudioToolbox
import AVFoundation
import Foundation

enum FlapSoundMode: Int, CaseIterable, Identifiable {
    case none = 0
    case bundled = 1
    case system = 2
    case custom = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .none:
            return "None"
        case .bundled:
            return "Flap"
        case .system:
            return "System"
        case .custom:
            return "Custom"
        }
    }
}

struct SystemSoundOption: Identifiable, Hashable {
    let id: Int
    let name: String
}

struct BundledSoundOption: Identifiable, Hashable {
    let id: String
    let name: String
    let fileName: String
    let fileExtension: String
}

enum FlapSoundDefaults {
    static let bundledExtensions = ["wav", "m4a", "mp3", "aif", "aiff", "caf"]
    static let bundledOptions: [BundledSoundOption] = [
        BundledSoundOption(id: "flap", name: "Flap (Shorts)", fileName: "flap", fileExtension: "wav"),
        BundledSoundOption(id: "flap_long", name: "Flap (Long)", fileName: "flap_long", fileExtension: "wav")
    ]
    static let defaultBundledSoundName = "flap"
    static let systemSoundOptions: [SystemSoundOption] = [
        SystemSoundOption(id: 1104, name: "Tock"),
        SystemSoundOption(id: 1103, name: "Tink"),
        SystemSoundOption(id: 1100, name: "Lock")
    ]
    static let defaultSystemSoundID = 1104
}

struct FlapSoundSelection: Equatable {
    var mode: FlapSoundMode
    var systemSoundID: Int
    var customSoundName: String
    var bundledSoundName: String

    var customSoundURL: URL? {
        guard !customSoundName.isEmpty else {
            return nil
        }
        return FlapSoundStorage.storedURL(for: customSoundName)
    }
}

enum FlapSoundStorage {
    private static let directoryName = "FlapSounds"

    static func storedURL(for fileName: String) -> URL? {
        guard let directory = storageDirectory() else {
            return nil
        }
        return directory.appendingPathComponent(fileName)
    }

    static func importSound(from url: URL) -> String? {
        guard let directory = storageDirectory() else {
            return nil
        }

        let fileName = url.lastPathComponent
        let destinationURL = directory.appendingPathComponent(fileName)
        let needsAccess = url.startAccessingSecurityScopedResource()
        defer {
            if needsAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: url, to: destinationURL)
            return fileName
        } catch {
            return nil
        }
    }

    private static func storageDirectory() -> URL? {
        guard let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let directory = baseURL.appendingPathComponent(directoryName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                return nil
            }
        }
        return directory
    }
}

final class FlapSoundPlayer {
    static let shared = FlapSoundPlayer()

    func hasBundledSound(named name: String) -> Bool {
        bundledSoundURL(for: name) != nil
    }

    private var bundledSoundName: String = ""
    private var bundledPlayers: [AVAudioPlayer] = []
    private var bundledPlayerIndex = 0
    private var bundledSoundURLCache: URL?
    private var customSoundName: String = ""
    private var customPlayers: [AVAudioPlayer] = []
    private var customPlayerIndex = 0
    private var didConfigureAudioSession = false

    func play(_ selection: FlapSoundSelection) {
        switch selection.mode {
        case .none:
            return
        case .bundled:
            playBundledSound(named: selection.bundledSoundName)
        case .system:
            AudioServicesPlaySystemSound(SystemSoundID(selection.systemSoundID))
        case .custom:
            playCustomSound(selection)
        }
    }

    private func playBundledSound(named name: String) {
        guard let soundURL = bundledSoundURL(for: name) else {
            return
        }

        if soundURL != bundledSoundURLCache || name != bundledSoundName {
            loadBundledSound(from: soundURL, name: name)
        }

        guard !bundledPlayers.isEmpty else {
            return
        }

        let player = bundledPlayers[bundledPlayerIndex]
        bundledPlayerIndex = (bundledPlayerIndex + 1) % bundledPlayers.count
        player.currentTime = 0
        player.play()
    }

    private func playCustomSound(_ selection: FlapSoundSelection) {
        guard let soundURL = selection.customSoundURL else {
            return
        }

        if selection.customSoundName != customSoundName {
            loadCustomSound(from: soundURL, fileName: selection.customSoundName)
        }

        guard !customPlayers.isEmpty else {
            return
        }

        let player = customPlayers[customPlayerIndex]
        customPlayerIndex = (customPlayerIndex + 1) % customPlayers.count
        player.currentTime = 0
        player.play()
    }

    private func loadBundledSound(from url: URL, name: String) {
        bundledSoundURLCache = url
        bundledSoundName = name
        bundledPlayers.removeAll()
        bundledPlayerIndex = 0

        configureAudioSessionIfNeeded()

        let maxPlayers = 6
        for _ in 0..<maxPlayers {
            if let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                bundledPlayers.append(player)
            }
        }
    }

    private func loadCustomSound(from url: URL, fileName: String) {
        customSoundName = fileName
        customPlayers.removeAll()
        customPlayerIndex = 0

        configureAudioSessionIfNeeded()

        let maxPlayers = 6
        for _ in 0..<maxPlayers {
            if let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                customPlayers.append(player)
            }
        }
    }

    private func configureAudioSessionIfNeeded() {
        guard !didConfigureAudioSession else {
            return
        }
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: [.mixWithOthers])
        try? session.setActive(true)
        didConfigureAudioSession = true
    }

    private func bundledSoundURL(for name: String) -> URL? {
        if let option = FlapSoundDefaults.bundledOptions.first(where: { $0.id == name || $0.fileName == name }) {
            if let url = Bundle.main.url(forResource: option.fileName, withExtension: option.fileExtension) {
                return url
            }
        }
        for ext in FlapSoundDefaults.bundledExtensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        for ext in FlapSoundDefaults.bundledExtensions {
            if let url = Bundle.main.url(forResource: FlapSoundDefaults.defaultBundledSoundName, withExtension: ext) {
                return url
            }
        }
        return nil
    }
}
