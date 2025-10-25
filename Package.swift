// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tabula",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "Tabula",
            targets: ["Tabula"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/thecoolwinter/SwiftTerm.git", branch: "codeedit")
    ],
    targets: [
        .executableTarget(
            name: "Tabula",
            dependencies: ["SwiftTerm"],
            path: "Sources"
        )
    ]
)
