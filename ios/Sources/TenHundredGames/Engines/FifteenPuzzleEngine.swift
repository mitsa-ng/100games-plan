import Foundation

struct FifteenPuzzleSnapshot: Codable, Hashable, Sendable {
    var tiles: [Int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0]  // 0 = 空位
    var moves: Int = 0
    var timeSeconds: Int = 0
    var isGameOver: Bool = false
    var isWon: Bool = false
}

final class FifteenPuzzleEngine: ObservableObject {
    @Published private(set) var tiles: [Int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0]
    @Published private(set) var moves: Int = 0
    @Published private(set) var timeSeconds: Int = 0
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var isWon: Bool = false

    private var random = SystemRandomNumberGenerator()

    init(random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.random = random
        shuffle()
    }

    convenience init(snapshot: FifteenPuzzleSnapshot, random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.init(random: random)
        self.tiles = snapshot.tiles
        self.moves = snapshot.moves
        self.timeSeconds = snapshot.timeSeconds
        self.isGameOver = snapshot.isGameOver
        self.isWon = snapshot.isWon
    }

    func shuffle() {
        moves = 0
        timeSeconds = 0
        isGameOver = false
        isWon = false
        // 產生有解的隨機排列
        repeat {
            tiles = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0].shuffled()
        } while !isSolvable(tiles) || isSolved(tiles)
    }

    private func isSolvable(_ tiles: [Int]) -> Bool {
        var inversions = 0
        let nonZero = tiles.filter { $0 != 0 }
        for i in 0..<nonZero.count {
            for j in (i+1)..<nonZero.count {
                if nonZero[i] > nonZero[j] { inversions += 1 }
            }
        }
        // 4x4 棋盤：空位從下往上數第幾行 (從底部算)
        let emptyRowFromBottom = 4 - (tiles.firstIndex(of: 0)! / 4)
        return (emptyRowFromBottom % 2 == 0) ? (inversions % 2 == 1) : (inversions % 2 == 0)
    }

    private func isSolved(_ tiles: [Int]) -> Bool {
        return tiles == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0]
    }

    func moveTile(at index: Int) {
        guard !isGameOver, !isWon else { return }
        guard index >= 0 && index < 16 else { return }
        guard tiles[index] != 0 else { return }

        let emptyIndex = tiles.firstIndex(of: 0)!
        let (er, ec) = (emptyIndex / 4, emptyIndex % 4)
        let (tr, tc) = (index / 4, index % 4)

        // 必須同行或同列且相鄰（或者同行/同列中間沒有其他非空方塊，簡化為相鄰）
        guard (er == tr && abs(ec - tc) == 1) || (ec == tc && abs(er - tr) == 1) else { return }

        tiles.swapAt(emptyIndex, index)
        moves += 1
        if isSolved(tiles) {
            isWon = true
            isGameOver = true
        }
    }

    func snapshot() -> FifteenPuzzleSnapshot {
        FifteenPuzzleSnapshot(tiles: tiles, moves: moves, timeSeconds: timeSeconds,
                              isGameOver: isGameOver, isWon: isWon)
    }
}
