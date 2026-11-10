import Foundation

enum GameId: String, CaseIterable, Codable, Hashable, Sendable {
    case game2048 = "2048"
    case tetris = "tetris"
    case snake = "snake"
    case breakout = "breakout"
    case minesweeper = "minesweeper"
    case memory = "memory"
    case sudoku = "sudoku"
    case ticTacToe = "tic_tac_toe"
    case fifteenPuzzle = "fifteen_puzzle"
    case reaction = "reaction"
    case dino = "dino"
    case ballBattle = "ball_battle"
    case eatcat = "eatcat"

    var slug: String { rawValue }
}
