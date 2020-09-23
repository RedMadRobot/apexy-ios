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
        .library(name: "Apexy", targets: ["Apexy_URLSession"]),
        .library(name: "Apexy_Alamofire", targets: ["Apexy_Alamofire"]),
        .library(name: "Apexy_RxSwift", targets: ["Apexy_RxSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.2.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "Apexy_RxSwift", dependencies: ["Apexy", "RxSwift"]),
        .target(name: "Apexy_Alamofire", dependencies: ["Apexy", "Alamofire"]),
        .target(name: "Apexy_URLSession", dependencies: ["Apexy"]),
        .target(name: "Apexy"),
        
        .testTarget(name: "ApexyAlamofireTests", dependencies: ["Apexy_Alamofire"]),
        .testTarget(name: "ApexyURLSessionTests", dependencies: ["Apexy_URLSession"]),
        .testTarget(name: "ApexyTests", dependencies: ["Apexy"])
    ]
)
