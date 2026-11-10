// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TenHundredGames",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "TenHundredGames",
            targets: ["TenHundredGames"]),
        .executable(
            name: "TenHundredGamesApp",
            targets: ["TenHundredGamesApp"]),
    ],
    targets: [
        .target(
            name: "TenHundredGames",
            dependencies: [],
            resources: [
                .process("Resources"),
            ]),
        .executableTarget(
            name: "TenHundredGamesApp",
            dependencies: ["TenHundredGames"],
            path: "Sources/TenHundredGamesApp"
        ),
        .testTarget(
            name: "TenHundredGamesTests",
            dependencies: ["TenHundredGames"],
            path: "Tests/TenHundredGamesTests"
        ),
    ]
)
