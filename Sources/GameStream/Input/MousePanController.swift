import Foundation

#if canImport(UIKit)
import UIKit
#endif

public final class MousePanController {
    public var offsetX: Double = 0
    public var offsetY: Double = 0
    public var scale: Double = 1.0

    public var settings: MouseSettings = .init()
    public var viewport: ViewportSettings = .init()

    public var onHostMouseMove: ((Double, Double) -> Void)?
    public var onHostMouseButton: ((UInt32, Bool) -> Void)?

    public init() {}

    public func dragChanged(dx: Double, dy: Double) {
        if viewport.panEnabled {
            offsetX += dx
            offsetY += dy
        }
        
        let mx = dx * settings.sensitivity
        let my = dy * settings.sensitivity * (settings.invertY ? -1 : 1)
        
        if abs(mx) > 0.5 || abs(my) > 0.5 {
            onHostMouseMove?(mx, my)
        }
    }

    public func tap(button: UInt32 = 1) {
        onHostMouseButton?(button, true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.onHostMouseButton?(button, false)
        }
    }

    public func longPress(button: UInt32 = 2) {
        onHostMouseButton?(button, true)
    }

    public func longPressEnded(button: UInt32 = 2) {
        onHostMouseButton?(button, false)
    }
}
