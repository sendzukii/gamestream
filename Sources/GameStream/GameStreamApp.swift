import Foundation

#if canImport(SwiftUI)
import SwiftUI

@main
public struct GameStreamApp: App {
    public init() {}
    public var body: some Scene {
        WindowGroup {
            ConnectionListView()
        }
    }
}
#else
public struct GameStreamApp {
    public static func main() {
        print("GameStream CLI test mode (Linux)")
        let profile = ConnectionProfile(name: "Test", host: "127.0.0.1", username: "user")
        
        print("--- Testing VNC ---")
        let vnc = VNCSessionBridge(profile: profile)
        vnc.onFrame = { data, w, h in
            print("VNC frame: \(w)x\(h), \(data.count) bytes")
        }
        vnc.start()
        
        print("--- Testing RDP ---")
        let rdp = RDPSessionBridge(profile: profile)
        rdp.onFrame = { data, w, h in
            print("RDP frame: \(w)x\(h), \(data.count) bytes")
        }
        try? rdp.start()
    }
}

@main
struct Main {
    static func main() {
        GameStreamApp.main()
    }
}
#endif
