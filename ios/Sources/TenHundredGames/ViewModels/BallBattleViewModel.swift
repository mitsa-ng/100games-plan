import SwiftUI

@MainActor
final class BallBattleViewModel: BaseGameViewModel {
    @Published private(set) var engine: BallBattleEngine = BallBattleEngine()
    private var gameTimer: Timer?

    override var gameId: GameId { .ballBattle }

    override func startNewGame() {
        engine = BallBattleEngine()
        engine.startNewGame()
        score = 0
        isGameOver = false
        showingGameOver = false
    }

    func updatePlayerPosition(x: Double, y: Double, screenWidth: Double, screenHeight: Double) {
        guard !isGameOver else { return }
        engine.tick()
        score = engine.score
        isGameOver = engine.isGameOver
        if isGameOver {
            endGame(finalScore: score)
        } else {
            app.playSound(.move)
        }
    }
}
