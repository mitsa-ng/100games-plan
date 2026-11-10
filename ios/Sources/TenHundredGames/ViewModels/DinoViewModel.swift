import SwiftUI

@MainActor
final class DinoViewModel: BaseGameViewModel {
    @Published private(set) var engine: DinoEngine = DinoEngine()
    private var gameTimer: Timer?

    override var gameId: GameId { .dino }

    override func startNewGame() {
        engine = DinoEngine()
        engine.startNewGame()
        score = 0
        isGameOver = false
        showingGameOver = false
        startTimer()
    }

    private func startTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        engine.tick(screenWidth: 0)
        score = engine.score
        isGameOver = engine.isGameOver
        if isGameOver {
            gameTimer?.invalidate()
            endGame(finalScore: score)
        } else {
            app.playSound(.move)
        }
    }

    func jump() {
        engine.jump()
        app.playSound(.tap)
        app.haptic(.light)
    }
}
