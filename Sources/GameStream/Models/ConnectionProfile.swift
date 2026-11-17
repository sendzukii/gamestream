import Foundation

public struct ConnectionProfile: Identifiable, Codable, Hashable {
    public var id: UUID = UUID()
    public var name: String
    public var host: String
    public var port: Int = 3389
    public var username: String
    public var domain: String = ""
    public var password: String = ""
    public var protocolKind: ProtocolKind = .rdp

    public enum ProtocolKind: String, Codable, CaseIterable, Identifiable {
        case rdp = "RDP"
        case vnc = "VNC"
        public var id: String { rawValue }
    }

    public init(id: UUID = UUID(), name: String, host: String, port: Int = 3389, username: String, domain: String = "", password: String = "", protocolKind: ProtocolKind = .rdp) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.username = username
        self.domain = domain
        self.password = password
        self.protocolKind = protocolKind
    }
}
