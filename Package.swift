// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Apexy",
    platforms: [
      .macOS(.v10_12),
      .iOS(.v10),
      .tvOS(.v10),
      .watchOS(.v4)
    ],
    products: [
        .library(name: "Apexy", targets: ["Apexy"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.2.0"))
    ],
    targets: [
        .target(name: "Apexy", dependencies: ["Alamofire"]),
    ]
)
