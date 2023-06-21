// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Apexy",
    platforms: [
      .macOS(.v10_13),
      .iOS(.v11),
      .tvOS(.v11),
      .watchOS(.v4)
    ],
    products: [
        .library(name: "Apexy", targets: ["ApexyURLSession"]),
        .library(name: "ApexyAlamofire", targets: ["ApexyAlamofire"]),
        .library(name: "ApexyLoader", targets: ["ApexyLoader"])
    ],
    dependencies: [
        .package(url: "git@github.com:Alamofire/Alamofire.git", .upToNextMajor(from: "5.2.0"))
    ],
    targets: [
        .target(name: "ApexyLoader", dependencies: ["Apexy"]),
        .target(name: "ApexyAlamofire", dependencies: ["Apexy", "Alamofire"]),
        .target(name: "ApexyURLSession", dependencies: ["Apexy"]),
        .target(name: "Apexy"),
        
        .testTarget(name: "ApexyLoaderTests", dependencies: ["ApexyLoader"]),
        .testTarget(name: "ApexyAlamofireTests", dependencies: ["ApexyAlamofire"]),
        .testTarget(name: "ApexyURLSessionTests", dependencies: ["ApexyURLSession"]),
        .testTarget(name: "ApexyTests", dependencies: ["Apexy"])
    ]
)
