import Foundation

enum MoveDirection2048: String, CaseIterable, Codable, Sendable {
    case up, down, left, right
}

struct Tile2048: Codable, Hashable, Sendable, Identifiable {
    let id: Int
    let value: Int
    let row: Int
    let col: Int
}

struct Snapshot2048: Codable, Hashable, Sendable {
    var tiles: [Tile2048] = []
    var score: Int = 0
    var nextTileId: Int = 1
    var isGameOver: Bool = false
}

struct TileMotion2048: Codable, Hashable, Sendable, Identifiable {
    let id = UUID()
    let tileId: Int
    let value: Int
    let fromRow: Int
    let fromCol: Int
    let toRow: Int
    let toCol: Int
}

struct MoveAnimation2048: Codable, Hashable, Sendable {
    let id: UUID
    let motions: [TileMotion2048]
}

final class Game2048Engine: ObservableObject {
    static let boardSize = 4

    @Published private(set) var tiles: [Tile2048] = []
    @Published private(set) var score: Int = 0
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var currentAnimation: MoveAnimation2048?

    private var nextTileId: Int = 1
    private var undoState: ([Tile2048], Int)? = nil
    private var hasUsedUndo: Bool = false
    private var animationCounter: Int = 0
    private let random: RandomNumberGenerator

    var boardTiles: [Tile2048] { tiles }
    var currentScore: Int { score }
    var gameOver: Bool { isGameOver }
    var canUndo: Bool { undoState != nil && !hasUsedUndo }
    var largestTile: Int { tiles.map { $0.value }.max() ?? 0 }

    init(random: SystemRandomNumberGenerator = SystemRandomNumberGenerator(),
         snapshot: Snapshot2048 = Snapshot2048()) {
        self.random = random
        self.tiles = snapshot.tiles
        self.score = snapshot.score
        self.nextTileId = snapshot.nextTileId
        self.isGameOver = snapshot.isGameOver
        if let undo = snapshot.undoState {
            self.undoState = (undo.tiles, undo.score)
        }
        self.hasUsedUndo = snapshot.hasUsedUndo
    }

    convenience init() {
        self.init(random: SystemRandomNumberGenerator(), snapshot: Snapshot2048())
        spawnRandomTile()
        spawnRandomTile()
    }

    func move(_ direction: MoveDirection2048) {
        guard !isGameOver else { return }

        let beforeTiles = tiles
        let beforeScore = score
        var newTiles: [Tile2048] = []
        var motions: [TileMotion2048] = []
        var gained = 0
        var merged = false
        var nextId = nextTileId

        for lineIndex in 0..<Self.boardSize {
            let line = tilesForLine(direction, lineIndex: lineIndex)
            var writeIndex = 0
            var index = 0

            while index < line.count {
                let first = line[index]
                let target = targetCell(direction, lineIndex: lineIndex, writeIndex: writeIndex)

                if index + 1 < line.count && line[index + 1].value == first.value {
                    let second = line[index + 1]
                    motions.append(TileMotion2048(tileId: first.id, value: first.value,
                                                  fromRow: first.row, fromCol: first.col,
                                                  toRow: target.row, toCol: target.col))
                    motions.append(TileMotion2048(tileId: second.id, value: second.value,
                                                  fromRow: second.row, fromCol: second.col,
                                                  toRow: target.row, toCol: target.col))
                    let mergedValue = first.value * 2
                    gained += mergedValue
                    merged = true
                    newTiles.append(Tile2048(id: nextId, value: mergedValue,
                                             row: target.row, col: target.col))
                    nextId += 1
                    index += 2
                } else {
                    motions.append(TileMotion2048(tileId: first.id, value: first.value,
                                                  fromRow: first.row, fromCol: first.col,
                                                  toRow: target.row, toCol: target.col))
                    newTiles.append(Tile2048(id: first.id, value: first.value,
                                             row: target.row, col: target.col))
                    index += 1
                }
                writeIndex += 1
            }
        }

        let movedByPosition = motions.contains { $0.fromRow != $0.toRow || $0.fromCol != $0.toCol }
        if !movedByPosition && !merged { return }

        undoState = (beforeTiles, beforeScore)
        tiles = newTiles
        score = beforeScore + gained
        nextTileId = nextId
        spawnRandomTile()
        isGameOver = !hasAvailableMove()

        animationCounter += 1
        currentAnimation = MoveAnimation2048(id: UUID(), motions: motions)
    }

    func undo() {
        guard !hasUsedUndo, let previous = undoState else { return }
        tiles = previous.0
        score = previous.1
        undoState = nil
        hasUsedUndo = true
        isGameOver = false
    }

    func snapshot() -> Snapshot2048 {
        Snapshot2048(tiles: tiles, score: score, nextTileId: nextTileId, isGameOver: isGameOver)
    }

    private func tilesForLine(_ direction: MoveDirection2048, lineIndex: Int) -> [Tile2048] {
        let line: [Tile2048]
        switch direction {
        case .left, .right:
            line = tiles.filter { $0.row == lineIndex }
        case .up, .down:
            line = tiles.filter { $0.col == lineIndex }
        }

        switch direction {
        case .left, .up:
            return line.sorted { direction == .left ? $0.col < $1.col : $0.row < $1.row }
        case .right, .down:
            return line.sorted { direction == .right ? $0.col > $1.col : $0.row > $1.row }
        }
    }

    private func targetCell(_ direction: MoveDirection2048, lineIndex: Int, writeIndex: Int) -> (row: Int, col: Int) {
        switch direction {
        case .left: return (lineIndex, writeIndex)
        case .right: return (lineIndex, Self.boardSize - 1 - writeIndex)
        case .up: return (writeIndex, lineIndex)
        case .down: return (Self.boardSize - 1 - writeIndex, lineIndex)
        }
    }

    private func spawnRandomTile() {
        let occupied = Set(tiles.map { "\($0.row),\($0.col)" })
        var emptyCells: [(Int, Int)] = []
        for row in 0..<Self.boardSize {
            for col in 0..<Self.boardSize {
                if !occupied.contains("\(row),\(col)") {
                    emptyCells.append((row, col))
                }
            }
        }
        guard !emptyCells.isEmpty else { return }

        let cell = emptyCells[Int.random(in: 0..<emptyCells.count)]
        let value = Int.random(in: 0..<10) == 0 ? 4 : 2
        tiles.append(Tile2048(id: nextTileId, value: value, row: cell.0, col: cell.1))
        nextTileId += 1
    }

    private func hasAvailableMove() -> Bool {
        if tiles.count < Self.boardSize * Self.boardSize { return true }
        var values = Array(repeating: Array(repeating: 0, count: Self.boardSize), count: Self.boardSize)
        tiles.forEach { values[$0.row][$0.col] = $0.value }
        for row in 0..<Self.boardSize {
            for col in 0..<Self.boardSize {
                let value = values[row][col]
                if row + 1 < Self.boardSize && values[row + 1][col] == value { return true }
                if col + 1 < Self.boardSize && values[row][col + 1] == value { return true }
            }
        }
        return false
    }
}

private extension Int {
    static func random<T: RandomNumberGenerator>(in range: Range<Int>, using generator: inout T) -> Int {
        Int.random(in: range, using: &generator)
    }
}

private struct SnapshotUndo: Codable, Hashable, Sendable {
    let tiles: [Tile2048]
    let score: Int
}

private extension Snapshot2048 {
    var undoState: SnapshotUndo? { nil }
    var hasUsedUndo: Bool { false }
}
