import Foundation

enum GameCategory: String, Codable, Hashable, Sendable {
    case puzzle = "益智"
    case arcade = "街机"
    case strategy = "策略"
    case casual = "休闲"

    var label: String { rawValue }
}
