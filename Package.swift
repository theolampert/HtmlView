// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HtmlView",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HtmlView",
            targets: ["HtmlView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher", exact: "7.11.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup", exact: "2.7.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HtmlView",
            dependencies: ["Kingfisher", "SwiftSoup"]
        ),
        .testTarget(
            name: "HtmlViewTests",
            dependencies: ["HtmlView"]),
    ]
)
