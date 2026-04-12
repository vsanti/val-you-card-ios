// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ValYouCard",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ValYouCard", targets: ["ValYouCard"]),
    ],
    targets: [
        .target(
            name: "ValYouCard",
            path: "ValYouCard"
        ),
    ]
)
