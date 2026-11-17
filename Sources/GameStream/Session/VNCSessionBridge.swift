import Foundation

#if canImport(Network)
import Network

public final class VNCSessionBridge {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "vnc", qos: .userInteractive)
    private let profile: ConnectionProfile
    private var width = 0
    private var height = 0
    public var onFrame: ((Data, Int, Int) -> Void)?

    public init(profile: ConnectionProfile) { self.profile = profile }

    public func start() {
        let host = NWEndpoint.Host(profile.host)
        let port = NWEndpoint.Port(integerLiteral: UInt16(profile.port))
        let conn = NWConnection(host: host, port: port, using: .tcp)
        connection = conn
        conn.stateUpdateHandler = { [weak self] state in
            if case .ready = state { self?.handshake() }
        }
        conn.start(queue: queue)
    }

    private func handshake() {
        receive(exactly: 12) { [weak self] data in
            guard let self, data.count == 12 else { return }
            self.send(Data("RFB 003.008\n".utf8))
            self.receive(exactly: 1) { sec in
                guard let sec, let n = sec.first else { return }
                self.receive(exactly: Int(n)) { types in
                    guard let types, types.contains(1) else { return }
                    self.send(Data([1]))
                    self.receive(exactly: 4) { _ in
                        self.sendSecurityResultAndInit()
                    }
                }
            }
        }
    }

    private func sendSecurityResultAndInit() {
        send(Data([1]))
        send(Data([1]))
        receive(exactly: 24) { [weak self] data in
            guard let self, let data, data.count == 24 else { return }
            let w = Int(data[0]) << 8 | Int(data[1])
            let h = Int(data[2]) << 8 | Int(data[3])
            self.width = w
            self.height = h
            var pf = Data()
            pf.append(contentsOf: [0,0,0,0])
            pf.append(contentsOf: [32,24,0,1])
            pf.append(contentsOf: [0,255,0,255,0,255])
            pf.append(contentsOf: [16,8,0])
            pf.append(contentsOf: [0,0,0])
            self.send(pf)
            var enc = Data()
            enc.append(0)
            enc.append(contentsOf: [0,0])
            enc.append(contentsOf: [0,0,0,1])
            enc.append(contentsOf: [0,0,0,0])
            self.send(enc)
            self.requestFullUpdate()
            self.readLoop()
        }
    }

    private func requestFullUpdate() {
        var req = Data([3, 0])
        req.append(contentsOf: [0,0,0,0, 0,0, 0,0, UInt8(width >> 8), UInt8(width & 0xff), UInt8(height >> 8), UInt8(height & 0xff)])
        send(req)
    }

    private func readLoop() {
        receive(exactly: 1) { [weak self] msgType in
            guard let self, let msgType, let t = msgType.first else { return }
            switch t {
            case 0:
                self.receive(exactly: 3) { hdr in
                    guard let hdr, hdr.count == 3 else { return }
                    let n = Int(hdr[1]) << 8 | Int(hdr[2])
                    self.readRects(count: n, accumulated: [])
                }
            case 1:
                self.receive(exactly: 5) { _ in self.readLoop() }
            case 2:
                self.readLoop()
            case 3:
                self.receive(exactly: 7) { hdr in
                    guard let hdr, hdr.count == 7 else { return }
                    let len = Int(hdr[3]) << 24 | Int(hdr[4]) << 16 | Int(hdr[5]) << 8 | Int(hdr[6])
                    self.receive(exactly: len) { _ in self.readLoop() }
                }
            default:
                self.readLoop()
            }
        }
    }

    private func readRects(count: Int, accumulated: [Data]) {
        if count == 0 {
            if let frame = accumulated.first {
                onFrame?(frame, width, height)
            }
            requestFullUpdate()
            readLoop()
            return
        }
        receive(exactly: 12) { [weak self] hdr in
            guard let self, let hdr, hdr.count == 12 else { return }
            let w = Int(hdr[4]) << 8 | Int(hdr[5])
            let h = Int(hdr[6]) << 8 | Int(hdr[7])
            let len = w * h * 4
            self.receive(exactly: len) { pixels in
                guard let pixels else { return }
                self.readRects(count: count - 1, accumulated: accumulated + [pixels])
            }
        }
    }

    public func sendKey(_ keyCode: UInt32, down: Bool) {
        var msg = Data([4])
        msg.append(down ? 1 : 0)
        msg.append(contentsOf: [0,0])
        msg.append(contentsOf: [
            UInt8((keyCode >> 24) & 0xff),
            UInt8((keyCode >> 16) & 0xff),
            UInt8((keyCode >> 8) & 0xff),
            UInt8(keyCode & 0xff)
        ])
        send(msg)
    }

    public func sendMouse(moveX: Int, moveY: Int, buttonMask: UInt8) {
        var msg = Data([5, buttonMask])
        msg.append(contentsOf: [UInt8(moveX >> 8), UInt8(moveX & 0xff)])
        msg.append(contentsOf: [UInt8(moveY >> 8), UInt8(moveY & 0xff)])
        send(msg)
    }

    public func stop() { connection?.cancel() }

    private func send(_ data: Data) {
        connection?.send(content: data, completion: .idempotent)
    }

    private func receive(exactly count: Int, _ completion: @escaping (Data?) -> Void) {
        connection?.receive(minimumIncompleteLength: count, maximumLength: count) { data, _, _, _ in
            completion(data)
        }
    }
}

#else
public final class VNCSessionBridge {
    public var onFrame: ((Data, Int, Int) -> Void)?
    public init(profile: ConnectionProfile) {}
    public func start() { print("VNC requires Network.framework (iOS/macOS)") }
    public func sendKey(_ keyCode: UInt32, down: Bool) {}
    public func sendMouse(moveX: Int, moveY: Int, buttonMask: UInt8) {}
    public func stop() {}
}
#endif
