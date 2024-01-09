// swift-tools-version: 5.8.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VLStoreKit",
    platforms: [
        .iOS(.v14),
        .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "VLStoreKit",
            targets: ["VLStoreKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/farazvl/VLBeaconSwift.git", branch: "beacon_fix"),
        .package(url: "https://github.com/socketio/socket.io-client-swift.git", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "VLStoreKit",
            dependencies: [
                .product(name: "VLBeaconLib", package: "VLBeaconSwift"),
                .product(name: "SocketIO", package: "socket.io-client-swift"),
//                .product(name: "Starscream", package: "Starscream")
            ]),
        .testTarget(
            name: "VLStoreKitTests",
            dependencies: ["VLStoreKit"]),
    ]
)

