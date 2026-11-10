import Foundation

enum TicTacToeAI: String, CaseIterable, Codable, Sendable {
    case random = "随机"
    case easy = "简单"
    case perfect = "完美"

    var label: String { rawValue }
}

struct TicTacToeSnapshot: Codable, Hashable, Sendable {
    var board: [Int] = Array(repeating: 0, count: 9)
    var aiLevel: TicTacToeAI = .perfect
    var winner: Int = 0
    var isDraw: Bool = false
}

final class TicTacToeEngine: ObservableObject {
    static let player = 1
    static let ai = 2

    @Published private(set) var board: [Int] = Array(repeating: 0, count: 9)
    @Published private(set) var winner: Int = 0
    @Published private(set) var isDraw: Bool = false
    @Published private(set) var isGameOver: Bool = false

    let aiLevel: TicTacToeAI
    private var random: any RandomNumberGenerator

    init(aiLevel: TicTacToeAI = .perfect, random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.aiLevel = aiLevel
        self.random = random
    }

    convenience init(snapshot: TicTacToeSnapshot) {
        self.init(aiLevel: snapshot.aiLevel, random: SystemRandomNumberGenerator())
        self.board = snapshot.board
        self.winner = snapshot.winner
        self.isDraw = snapshot.isDraw
        self.isGameOver = snapshot.winner != 0 || snapshot.isDraw
    }

    func cellAt(_ index: Int) -> Int {
        guard index >= 0 && index < 9 else { return 0 }
        return board[index]
    }

    func playPlayer(index: Int) -> Bool {
        guard !isGameOver, index >= 0, index < 9, board[index] == 0 else { return false }
        board[index] = Self.player
        evaluate()
        if !isGameOver {
            playAi()
        }
        return true
    }

    private func playAi() {
        guard !isGameOver else { return }
        let empty = board.indices.filter { board[$0] == 0 }
        guard !empty.isEmpty else { return }

        let index: Int
        switch aiLevel {
        case .random:
            index = empty.randomElement()!
        case .easy:
            if Int.random(in: 0..<100) < 65 {
                index = empty.randomElement()!
            } else {
                index = bestMove()
            }
        case .perfect:
            index = bestMove()
        }

        board[index] = Self.ai
        evaluate()
    }

    private func evaluate() {
        let lines: [[Int]] = [
            [0,1,2], [3,4,5], [6,7,8],
            [0,3,6], [1,4,7], [2,5,8],
            [0,4,8], [2,4,6],
        ]
        for line in lines {
            let first = board[line[0]]
            if first != 0 && first == board[line[1]] && first == board[line[2]] {
                winner = first
                isGameOver = true
                return
            }
        }
        if !board.contains(0) {
            isDraw = true
            isGameOver = true
        }
    }

    private func bestMove() -> Int {
        var bestScore = Int.min
        var bestIndex = -1
        for index in board.indices where board[index] == 0 {
            board[index] = Self.ai
            let score = minimax(isAiTurn: false)
            board[index] = 0
            if score > bestScore {
                bestScore = score
                bestIndex = index
            }
        }
        return bestIndex
    }

    private func minimax(isAiTurn: Bool) -> Int {
        let lines: [[Int]] = [
            [0,1,2], [3,4,5], [6,7,8],
            [0,3,6], [1,4,7], [2,5,8],
            [0,4,8], [2,4,6],
        ]
        for line in lines {
            let first = board[line[0]]
            if first != 0 && first == board[line[1]] && first == board[line[2]] {
                return first == Self.ai ? 10 : -10
            }
        }
        if !board.contains(0) { return 0 }

        if isAiTurn {
            var best = Int.min
            for index in board.indices where board[index] == 0 {
                board[index] = Self.ai
                best = max(best, minimax(isAiTurn: false))
                board[index] = 0
            }
            return best
        } else {
            var best = Int.max
            for index in board.indices where board[index] == 0 {
                board[index] = Self.player
                best = min(best, minimax(isAiTurn: true))
                board[index] = 0
            }
            return best
        }
    }

    func snapshot() -> TicTacToeSnapshot {
        TicTacToeSnapshot(board: board, aiLevel: aiLevel, winner: winner, isDraw: isDraw)
    }

    func reset() {
        board = Array(repeating: 0, count: 9)
        winner = 0
        isDraw = false
        isGameOver = false
    }
}
