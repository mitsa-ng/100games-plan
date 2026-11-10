import Foundation
import SwiftUI

enum ThemeMode: String, Codable, Hashable, Sendable {
    case system, light, dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum SnakeControlMode: String, Codable, Hashable, Sendable {
    case both, swipe, buttons
}

enum SnakeControlSide: String, Codable, Hashable, Sendable {
    case left, right
}

enum SnakeButtonSize: String, Codable, Hashable, Sendable {
    case small, medium, large
}

enum AppColorPalette: String, Codable, Hashable, Sendable {
    case brand, ocean, forest, sunset, berry
}

struct AppSettings: Codable, Hashable, Sendable {
    var themeMode: ThemeMode = .system
    var dynamicColorEnabled: Bool = true
    var colorPalette: AppColorPalette = .brand
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var predictiveBackEnabled: Bool = true
    var snakeControlMode: SnakeControlMode = .both
    var snakeControlSide: SnakeControlSide = .right
    var snakeButtonSize: SnakeButtonSize = .medium
    var reactionLatencyOffsetMs: Int = 0
    var reactionCalibrationSaved: Bool = false
    var nearbyRoomName: String = "我的房间"
}
