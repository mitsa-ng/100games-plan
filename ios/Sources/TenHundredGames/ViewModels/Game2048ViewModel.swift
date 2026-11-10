import SwiftUI

@MainActor
final class Game2048ViewModel: BaseGameViewModel {
    @Published private(set) var engine: Game2048Engine = Game2048Engine()
    @Published private(set) var animations: [MoveAnimation2048] = []

    override var gameId: GameId { .game2048 }

    override func startNewGame() {
        engine = Game2048Engine()
        animations = []
        score = 0
        isGameOver = false
        showingGameOver = false
    }

    func move(_ direction: MoveDirection2048) {
        guard !isGameOver else { return }
        engine.move(direction)
        score = engine.currentScore
        isGameOver = engine.gameOver

        if let anim = engine.currentAnimation {
            animations.append(anim)
            app.playSound(.move)
            app.haptic(.light)
        }

        if isGameOver {
            endGame(finalScore: score)
        }
    }

    func undo() {
        engine.undo()
        score = engine.currentScore
        isGameOver = engine.gameOver
        app.playSound(.tap)
    }
}
