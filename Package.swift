// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TerminalGroups",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "TerminalGroups",
            targets: ["TerminalGroups"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftTerm.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "TerminalGroups",
            dependencies: ["SwiftTerm"],
            path: "Sources"
        )
    ]
)
