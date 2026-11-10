import SwiftUI

@MainActor
final class MinesweeperViewModel: BaseGameViewModel {
    @Published private(set) var engine: MinesweeperEngine = MinesweeperEngine(rows: 9, cols: 9, mineCount: 10)

    override var gameId: GameId { .minesweeper }

    override func startNewGame() {
        engine = MinesweeperEngine(rows: 9, cols: 9, mineCount: 10)
        score = 0
        isGameOver = false
        showingGameOver = false
    }

    func reveal(at row: Int, col: Int) {
        engine.reveal(row: row, col: col)
        score = engine.revealedCount * 10
        isGameOver = engine.isGameOver
        if engine.isGameOver || engine.isWon {
            let final = engine.isWon ? score : -score
            endGame(finalScore: final)
        }
    }

    func toggleFlag(at row: Int, col: Int) {
        engine.toggleFlag(row: row, col: col)
        app.playSound(.tap)
        app.haptic(.light)
    }
}
