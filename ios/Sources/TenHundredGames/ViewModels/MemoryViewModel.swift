import SwiftUI

@MainActor
final class MemoryViewModel: BaseGameViewModel {
    @Published private(set) var engine: MemoryEngine = MemoryEngine()
    @Published var gridSize: Int = 16  // 4x4

    override var gameId: GameId { .memory }

    override func startNewGame() {
        engine.startNewGame(gridSize: gridSize)
        score = 0
        isGameOver = false
        showingGameOver = false
    }

    func flipCard(id: Int) {
        engine.flipCard(id: id)
        score = engine.moves
        isGameOver = engine.isGameOver
        if isGameOver {
            endGame(finalScore: engine.moves)
        } else {
            app.playSound(.tap)
        }
    }
}
