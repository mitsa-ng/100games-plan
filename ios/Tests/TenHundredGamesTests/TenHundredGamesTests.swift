import XCTest
@testable import TenHundredGames

final class TenHundredGamesTests: XCTestCase {
    func testGameCatalogNotEmpty() {
        XCTAssertGreaterThan(GameCatalog.all.count, 0)
    }

    func testSnakeEngineTick() {
        let engine = SnakeEngine()
        XCTAssertFalse(engine.isGameOver)
        engine.tick()
        // 蛇應該移動
        XCTAssertEqual(engine.snakeBody.count, 3)
    }

    func testTicTacToeWin() {
        let engine = TicTacToeEngine(aiLevel: .random)
        _ = engine.playPlayer(index: 0)
        _ = engine.playPlayer(index: 1)
        _ = engine.playPlayer(index: 3)
        _ = engine.playPlayer(index: 4)
        _ = engine.playPlayer(index: 6)
        XCTAssertTrue(engine.isGameOver)
        XCTAssertEqual(engine.winner, TicTacToeEngine.player)
    }

    func test2048Move() {
        let engine = Game2048Engine()
        let before = engine.score
        _ = engine.move(.down)
        XCTAssertTrue(engine.score >= before)
    }

    func testPlayerStats() {
        var stats = PlayerStats()
        XCTAssertEqual(stats.highScore(for: .snake), 0)
        stats.highScores[.snake] = 100
        XCTAssertEqual(stats.highScore(for: .snake), 100)
    }
}
