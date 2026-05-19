// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Neko",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Neko",
            path: "Sources/Neko",
            resources: [.copy("Resources/oneko.gif")]
        )
    ]
)
