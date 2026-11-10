import Foundation

struct MemoryCard: Codable, Hashable, Sendable, Identifiable {
    let id: Int
    var symbol: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

struct MemorySnapshot: Codable, Hashable, Sendable {
    var cards: [MemoryCard] = []
    var moves: Int = 0
    var timeSeconds: Int = 0
    var isGameOver: Bool = false
    var isWon: Bool = false
}

@MainActor
final class MemoryEngine: ObservableObject {
    private let symbols = ["🍎","🍌","🍇","🍉","🍓","🍒","🍍","🥝","🥥","🥑","🍅","🌽","🥕","🥔","🌶️","🍄"]

    @Published private(set) var cards: [MemoryCard] = []
    @Published private(set) var moves: Int = 0
    @Published private(set) var timeSeconds: Int = 0
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var isWon: Bool = false

    private var firstCardId: Int? = nil
    private var secondCardId: Int? = nil

    init() {}

    convenience init(snapshot: MemorySnapshot) {
        self.init()
        self.cards = snapshot.cards
        self.moves = snapshot.moves
        self.timeSeconds = snapshot.timeSeconds
        self.isGameOver = snapshot.isGameOver
        self.isWon = snapshot.isWon
    }

    func startNewGame(gridSize: Int) {
        cards = []
        moves = 0
        timeSeconds = 0
        isGameOver = false
        isWon = false
        firstCardId = nil
        secondCardId = nil

        let pairCount = gridSize / 2
        let selectedSymbols = Array(symbols.shuffled().prefix(pairCount))
        var allSymbols = selectedSymbols + selectedSymbols
        allSymbols.shuffle()

        for (index, symbol) in allSymbols.enumerated() {
            cards.append(MemoryCard(id: index, symbol: symbol))
        }
    }

    func flipCard(id: Int) {
        guard !isGameOver, !isWon else { return }
        guard let index = cards.firstIndex(where: { $0.id == id }) else { return }
        var card = cards[index]
        guard !card.isFaceUp, !card.isMatched else { return }

        card.isFaceUp = true
        cards[index] = card

        if firstCardId == nil {
            firstCardId = id
        } else if secondCardId == nil {
            secondCardId = id
            moves += 1
            checkMatch()
        }
    }

    private func checkMatch() {
        guard let firstId = firstCardId, let secondId = secondCardId else { return }
        guard let firstIndex = cards.firstIndex(where: { $0.id == firstId }),
              let secondIndex = cards.firstIndex(where: { $0.id == secondId }) else { return }

        if cards[firstIndex].symbol == cards[secondIndex].symbol {
            cards[firstIndex].isMatched = true
            cards[secondIndex].isMatched = true
            firstCardId = nil
            secondCardId = nil
            checkWin()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task { @MainActor in
                    var f = self.cards[self.cards.firstIndex(where: { $0.id == firstId })!]
                    var s = self.cards[self.cards.firstIndex(where: { $0.id == secondId })!]
                    f.isFaceUp = false
                    s.isFaceUp = false
                    self.cards[self.cards.firstIndex(where: { $0.id == firstId })!] = f
                    self.cards[self.cards.firstIndex(where: { $0.id == secondId })!] = s
                    self.firstCardId = nil
                    self.secondCardId = nil
                }
            }
        }
    }

    private func checkWin() {
        if cards.allSatisfy({ $0.isMatched }) {
            isWon = true
            isGameOver = true
        }
    }

    func snapshot() -> MemorySnapshot {
        MemorySnapshot(cards: cards, moves: moves, timeSeconds: timeSeconds,
                       isGameOver: isGameOver, isWon: isWon)
    }
}
