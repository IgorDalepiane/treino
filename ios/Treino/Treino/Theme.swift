import SwiftUI

enum Palette {
    static let bg = Color(hex: 0x0B0D11)
    static let bg2 = Color(hex: 0x12151C)
    static let bg3 = Color(hex: 0x1A1F29)
    static let line = Color(hex: 0x2A3140)
    static let text = Color(hex: 0xE8EDF5)
    static let muted = Color(hex: 0x8B95A8)
    static let pull = Color(hex: 0x5B9FD4)
    static let pullBg = Color(hex: 0x152230)
    static let legs = Color(hex: 0xD4A017)
    static let legsBg = Color(hex: 0x2A210C)
    static let push = Color(hex: 0xE07A6A)
    static let pushBg = Color(hex: 0x2A1614)
    static let run = Color(hex: 0x5CBF8A)
    static let runBg = Color(hex: 0x10241C)
    static let volei = Color(hex: 0x9B7AE0)
    static let voleiBg = Color(hex: 0x1C1730)
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

enum Accent {
    case pull, legs, push, run, volei

    var color: Color {
        switch self {
        case .pull: Palette.pull
        case .legs: Palette.legs
        case .push: Palette.push
        case .run: Palette.run
        case .volei: Palette.volei
        }
    }

    var background: Color {
        switch self {
        case .pull: Palette.pullBg
        case .legs: Palette.legsBg
        case .push: Palette.pushBg
        case .run: Palette.runBg
        case .volei: Palette.voleiBg
        }
    }
}
