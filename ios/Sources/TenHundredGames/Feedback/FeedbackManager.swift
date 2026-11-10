import Foundation
import AVFoundation
import CoreHaptics
#if canImport(UIKit)
import UIKit
#endif

final class FeedbackManager: ObservableObject, @unchecked Sendable {
    static let shared = FeedbackManager()

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var hapticEngine: CHHapticEngine?

    private let soundBundle: Bundle = .module

    private init() {
        setupHaptics()
        preloadSounds()
    }

    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            hapticEngine = nil
        }
    }

    private func preloadSounds() {
        let soundNames = [
            "feedback_tap", "feedback_move", "feedback_merge", "feedback_rotate",
            "feedback_drop", "feedback_clear", "feedback_eat", "feedback_win",
            "feedback_gameover", "feedback_error", "feedback_calibrate", "feedback_click",
        ]
        for name in soundNames {
            guard let url = soundBundle.url(forResource: name, withExtension: "wav") else { continue }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                audioPlayers[name] = player
            } catch {
                // 忽略缺失的音效資源
            }
        }
    }

    func play(_ sound: FeedbackSound) {
        playSound(sound.rawValue)
    }

    private func playSound(_ name: String) {
        guard let player = audioPlayers[name] else { return }
        player.currentTime = 0
        player.play()
    }

    func haptic(_ type: FeedbackHaptic) {
        #if canImport(UIKit)
        switch type {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .rigid:
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        case .soft:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        #endif
    }

}

enum FeedbackSound: String, Sendable {
    case tap, move, merge, rotate, drop, clear, eat, win, gameover, error, calibrate, click
}

enum FeedbackHaptic: Sendable {
    case light, medium, heavy, rigid, soft, error, success, warning
}
