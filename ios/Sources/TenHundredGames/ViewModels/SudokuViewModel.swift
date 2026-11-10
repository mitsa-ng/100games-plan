import SwiftUI

@MainActor
final class SudokuViewModel: BaseGameViewModel {
    @Published private(set) var engine: SudokuEngine = SudokuEngine()
    @Published var difficulty: SudokuDifficulty = .easy

    override var gameId: GameId { .sudoku }

    override func startNewGame() {
        engine = SudokuEngine()
        engine.newGame(difficulty: difficulty)
        score = 0
        isGameOver = false
        showingGameOver = false
    }

    func setValue(row: Int, col: Int, value: Int) {
        engine.setValue(row: row, col: col, value: value)
        score = engine.moves
        isGameOver = engine.isGameOver
        if isGameOver {
            endGame(finalScore: score)
        } else {
            app.playSound(.tap)
            app.haptic(.light)
        }
    }
}
