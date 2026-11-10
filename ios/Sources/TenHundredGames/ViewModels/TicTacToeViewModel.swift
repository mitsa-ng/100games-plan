import SwiftUI

@MainActor
final class TicTacToeViewModel: BaseGameViewModel {
    @Published private(set) var engine: TicTacToeEngine = TicTacToeEngine(aiLevel: .perfect)
    @Published var aiLevel: TicTacToeAI = .perfect

    override var gameId: GameId { .ticTacToe }

    override func startNewGame() {
        engine = TicTacToeEngine(aiLevel: aiLevel)
        score = 0
        isGameOver = false
        showingGameOver = false
    }

    func play(at index: Int) {
        guard !isGameOver else { return }
        let ok = engine.playPlayer(index: index)
        if ok {
            app.playSound(.tap)
            app.haptic(.light)
            score = engine.winner == TicTacToeEngine.player ? 1 : 0
        }
        if engine.isGameOver {
            let finalScore = engine.winner == TicTacToeEngine.player ? 1 :
                           engine.winner == TicTacToeEngine.ai ? -1 : 0
            endGame(finalScore: finalScore)
        }
    }

    func resetAI(_ level: TicTacToeAI) {
        aiLevel = level
        startNewGame()
    }
}
