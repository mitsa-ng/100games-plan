import SwiftUI

@MainActor
class BaseGameViewModel: ObservableObject {
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var isPaused: Bool = false
    @Published var showingGameOver: Bool = false

    let app: AppViewModel

    init(app: AppViewModel) {
        self.app = app
        startNewGame()
    }

    func startNewGame() {
        score = 0
        isGameOver = false
        showingGameOver = false
    }

    func endGame(finalScore: Int) {
        score = finalScore
        isGameOver = true
        showingGameOver = true
        app.recordPlay(gameId: gameId, score: finalScore)
        app.playSound(.gameover)
        app.haptic(.error)
    }

    var gameId: GameId {
        fatalError("Subclass must override gameId")
    }
}
