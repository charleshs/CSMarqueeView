// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "CSMarqueeView",
    platforms: [
        .iOS(.v11), .tvOS(.v11), .watchOS(.v4),
    ],
    products: [
        .library(name: "CSMarqueeView", targets: ["CSMarqueeView"]),
    ],
    targets: [
        .target(name: "CSMarqueeView", dependencies: []),
    ]
)
