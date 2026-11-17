import Foundation

#if canImport(FreeRDP)
import FreeRDP

public final class RDPSessionBridge {
    private var instance: OpaquePointer?
    private var context: OpaquePointer?
    private var running = false
    private let profile: ConnectionProfile
    public var onFrame: ((Data, Int, Int) -> Void)?

    public init(profile: ConnectionProfile) {
        self.profile = profile
    }

    public func start() throws {
        guard let ctx = freerdp_context_new() else {
            throw NSError(domain: "rdp", code: -1, userInfo: [NSLocalizedDescriptionKey: "context_new failed"])
        }
        context = ctx

        let settings = freerdp_context_get_settings(ctx)
        freerdp_settings_set_string(settings, FreeRDP_ServerHostname, profile.host)
        freerdp_settings_set_uint32(settings, FreeRDP_ServerPort, UInt32(profile.port))
        freerdp_settings_set_string(settings, FreeRDP_Username, profile.username)
        freerdp_settings_set_string(settings, FreeRDP_Password, profile.password)
        freerdp_settings_set_string(settings, FreeRDP_Domain, profile.domain)
        freerdp_settings_set_bool(settings, FreeRDP_UseUnwrappedRdpSecurity, true)
        freerdp_settings_set_bool(settings, FreeRDP_NlaSecurity, true)
        freerdp_settings_set_uint32(settings, FreeRDP_ColorDepth, 32)
        freerdp_settings_set_bool(settings, FreeRDP_SoftwareGdi, true)

        let inst = freerdp_new()
        instance = inst
        freerdp_context_set_peer(ctx, inst)

        if !freerdp_connect(ctx) {
            throw NSError(domain: "rdp", code: -2, userInfo: [NSLocalizedDescriptionKey: "connect failed"])
        }
        running = true

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.runLoop()
        }
    }

    private func runLoop() {
        guard let ctx = context else { return }
        while running {
            let rc = freerdp_check_fds(ctx)
            if rc < 0 { break }
            freerdp_check_event_handles(ctx)
            usleep(1000 * 16)
        }
        if let ctx = context {
            freerdp_disconnect(ctx)
            freerdp_context_free(ctx)
        }
        context = nil
        instance = nil
    }

    public func sendKey(_ keyCode: UInt32, down: Bool) {
        guard let ctx = context else { return }
        let flags: UInt32 = down ? 1 : 0
        freerdp_input_send_keyboard_event(ctx, flags, UInt32(keyCode), 0, 0)
    }

    public func sendMouse(moveX: Int, moveY: Int, button: UInt32, down: Bool) {
        guard let ctx = context else { return }
        let flags: UInt32 = down ? (1 << 0) : 0
        freerdp_input_send_mouse_event(ctx, flags, button, UInt16(moveX), UInt16(moveY))
    }

    public func stop() {
        running = false
    }
}

#else
// Заглушка для Linux
public final class RDPSessionBridge {
    public var onFrame: ((Data, Int, Int) -> Void)?
    public init(profile: ConnectionProfile) {}
    public func start() throws { print("RDP requires FreeRDP (iOS/macOS)") }
    public func sendKey(_ keyCode: UInt32, down: Bool) {}
    public func sendMouse(moveX: Int, moveY: Int, button: UInt32, down: Bool) {}
    public func stop() {}
}
#endif
