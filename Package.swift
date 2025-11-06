// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "zoom-pad",
    targets: [
        .executableTarget(
            name: "zoom-pad",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=minimal")
            ]
        )
    ]
)
