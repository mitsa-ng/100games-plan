import SwiftUI

@MainActor
final class ReactionViewModel: BaseGameViewModel {
    @Published private(set) var engine: ReactionEngine = ReactionEngine()
    @Published var currentReaction: Int? = nil

    override var gameId: GameId { .reaction }

    override func startNewGame() {
        engine = ReactionEngine()
        engine.startNewGame()
        score = 0
        currentReaction = nil
        isGameOver = false
        showingGameOver = false
    }

    func onTap() {
        let time = engine.onTap()
        currentReaction = time
        if let t = time {
            app.playSound(.tap)
            app.haptic(.light)
            score = t
        }
        if engine.isGameOver {
            let best = engine.bestReactionTime
            endGame(finalScore: best)
        }
    }

    func onFalseStart() {
        engine.onFalseStart()
        app.playSound(.error)
        app.haptic(.error)
        if engine.isGameOver {
            endGame(finalScore: 9999)
        }
    }

    var averageReactionTime: Int { engine.averageReactionTime }
    var bestReactionTime: Int { engine.bestReactionTime }
}
