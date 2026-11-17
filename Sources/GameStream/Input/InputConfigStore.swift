import Foundation

#if canImport(Combine)
import Combine

public final class InputConfigStore: ObservableObject {
    @Published public var config: InputConfiguration = .init()
    private let key = "gamestream.input.config"

    public init() { load() }

    public func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(InputConfiguration.self, from: data)
        else { return }
        config = decoded
    }

    public func save() {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    public func reset() {
        config = .init()
        save()
    }
}
#else
public final class InputConfigStore {
    public var config: InputConfiguration = .init()
    private let key = "gamestream.input.config"

    public init() { load() }

    public func load() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(key + ".json")
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(InputConfiguration.self, from: data)
        else { return }
        config = decoded
    }

    public func save() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(key + ".json")
        if let data = try? JSONEncoder().encode(config) {
            try? data.write(to: url)
        }
    }

    public func reset() {
        config = .init()
        save()
    }
}
#endif
