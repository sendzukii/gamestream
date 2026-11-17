import Foundation

public struct MouseButtonMapping: Codable, Equatable {
    public var primary: UInt32 = 1
    public var secondary: UInt32 = 2
    public var middle: UInt32 = 4
    public var forward: UInt32 = 8
    public var back: UInt32 = 16
    public init() {}
}

public struct KeyRemap: Codable, Equatable, Identifiable {
    public var id: UUID = UUID()
    public var physicalKey: UInt32
    public var virtualKey: UInt32
    public var label: String = ""
    public init(id: UUID = UUID(), physicalKey: UInt32, virtualKey: UInt32, label: String = "") {
        self.id = id
        self.physicalKey = physicalKey
        self.virtualKey = virtualKey
        self.label = label
    }
}

public struct ControllerMapping: Codable, Equatable {
    public var a: UInt32 = 0x1C
    public var b: UInt32 = 0x01
    public var x: UInt32 = 0x39
    public var y: UInt32 = 0x0F
    public var leftShoulder: UInt32 = 0x10
    public var rightShoulder: UInt32 = 0x12
    public var leftTrigger: UInt32 = 0x1D
    public var rightTrigger: UInt32 = 0x2A
    public var dpadUp: UInt32 = 0x48
    public var dpadDown: UInt32 = 0x50
    public var dpadLeft: UInt32 = 0x4B
    public var dpadRight: UInt32 = 0x4D
    public var leftStickClick: UInt32 = 0x0E
    public var rightStickClick: UInt32 = 0x1C
    public var start: UInt32 = 0x1C
    public var select: UInt32 = 0x0E
    public init() {}
}

public struct MouseSettings: Codable, Equatable {
    public var sensitivity: Double = 2.0
    public var scrollSensitivity: Double = 1.0
    public var invertY: Bool = false
    public var edgeScroll: Bool = true
    public var edgeScrollMargin: Double = 20
    public var buttons: MouseButtonMapping = .init()
    public init() {}
}

public struct ViewportSettings: Codable, Equatable {
    public var panEnabled: Bool = true
    public var panSpeed: Double = 1.0
    public var pinchZoomEnabled: Bool = true
    public var minScale: Double = 0.5
    public var maxScale: Double = 4.0
    public init() {}
}

public struct InputConfiguration: Codable, Equatable {
    public var keyRemaps: [KeyRemap] = []
    public var controller: ControllerMapping = .init()
    public var mouse: MouseSettings = .init()
    public var viewport: ViewportSettings = .init()

    public init() {}

    public func remap(_ physical: UInt32) -> UInt32 {
        keyRemaps.first(where: { $0.physicalKey == physical })?.virtualKey ?? physical
    }
}
