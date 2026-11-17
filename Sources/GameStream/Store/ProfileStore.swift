import Foundation

#if canImport(Combine)
import Combine

final class ProfileStore: ObservableObject {
    @Published var profiles: [ConnectionProfile] = []
    private let key = "gamestream.profiles"

    init() { load() }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([ConnectionProfile].self, from: data)
        else { return }
        profiles = decoded
    }

    func save() {
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func upsert(_ profile: ConnectionProfile) {
        if let idx = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[idx] = profile
        } else {
            profiles.append(profile)
        }
        save()
    }

    func delete(_ profile: ConnectionProfile) {
        profiles.removeAll { $0.id == profile.id }
        save()
    }
}

#else
// Заглушка для Linux (без Combine/SwiftUI)
final class ProfileStore {
    var profiles: [ConnectionProfile] = []
    private let key = "gamestream.profiles"

    init() { load() }

    func load() {
        // UserDefaults на Linux может быть недоступен, используем файл
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(key + ".json")
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([ConnectionProfile].self, from: data)
        else { return }
        profiles = decoded
    }

    func save() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(key + ".json")
        if let data = try? JSONEncoder().encode(profiles) {
            try? data.write(to: url)
        }
    }

    func upsert(_ profile: ConnectionProfile) {
        if let idx = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[idx] = profile
        } else {
            profiles.append(profile)
        }
        save()
    }

    func delete(_ profile: ConnectionProfile) {
        profiles.removeAll { $0.id == profile.id }
        save()
    }
}
#endif
