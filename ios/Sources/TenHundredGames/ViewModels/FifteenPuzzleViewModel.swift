import SwiftUI

@MainActor
final class FifteenPuzzleViewModel: BaseGameViewModel {
    @Published private(set) var engine: FifteenPuzzleEngine = FifteenPuzzleEngine()

    override var gameId: GameId { .fifteenPuzzle }

    override func startNewGame() {
        engine = FifteenPuzzleEngine()
        engine.shuffle()
        score = 0
        isGameOver = false
        showingGameOver = false
    }

    func moveTile(at index: Int) {
        engine.moveTile(at: index)
        score = engine.moves
        isGameOver = engine.isGameOver
        if isGameOver {
            endGame(finalScore: engine.moves)
        } else {
            app.playSound(.tap)
            app.haptic(.light)
        }
    }
}
