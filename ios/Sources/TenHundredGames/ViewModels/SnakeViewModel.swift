import SwiftUI

@MainActor
final class SnakeViewModel: BaseGameViewModel {
    @Published private(set) var engine: SnakeEngine = SnakeEngine()
    @Published var difficulty: SnakeDifficulty = .normal
    @Published var wrapAround: Bool = false
    private var gameTimer: Timer?

    override var gameId: GameId { .snake }

    override func startNewGame() {
        engine = SnakeEngine(difficulty: difficulty, wrapAround: wrapAround)
        score = 0
        isGameOver = false
        showingGameOver = false
        startTimer()
    }

    private func startTimer() {
        gameTimer?.invalidate()
        let interval = engine.tickIntervalMillis / 1000.0
        gameTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        engine.tick()
        score = engine.currentScore
        isGameOver = engine.isGameOver
        if isGameOver {
            gameTimer?.invalidate()
            endGame(finalScore: score)
        }
    }

    func turn(_ direction: SnakeDirection) {
        _ = engine.turn(direction)
        app.playSound(.move)
    }

    override func endGame(finalScore: Int) {
        super.endGame(finalScore: finalScore)
    }
}
