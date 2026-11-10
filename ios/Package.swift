// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TenHundredGames",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .executable(
            name: "TenHundredGames",
            targets: ["TenHundredGames"]),
    ],
    targets: [
        .executableTarget(
            name: "TenHundredGames",
            dependencies: [],
            path: "Sources/TenHundredGames",
            resources: [
                .process("Resources"),
            ]),
        .testTarget(
            name: "TenHundredGamesTests",
            dependencies: ["TenHundredGames"],
            path: "Tests/TenHundredGamesTests"
        ),
    ]
)
