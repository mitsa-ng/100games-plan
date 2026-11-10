import SwiftUI

@MainActor
final class BreakoutViewModel: BaseGameViewModel {
    @Published private(set) var engine: BreakoutEngine = BreakoutEngine()
    private var gameTimer: Timer?
    @Published var screenWidth: Double = 0
    @Published var screenHeight: Double = 0

    override var gameId: GameId { .breakout }

    override func startNewGame() {
        engine = BreakoutEngine()
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
        engine.tick(screenWidth: screenWidth, screenHeight: screenHeight)
        score = engine.score
        isGameOver = engine.isGameOver
        if isGameOver || engine.isWon {
            gameTimer?.invalidate()
            endGame(finalScore: score)
        }
    }

    func updatePaddle(x: Double) {
        engine.updatePaddle(x: x, screenWidth: screenWidth)
        engine.tick(screenWidth: screenWidth, screenHeight: screenHeight)
        score = engine.score
    }
}
