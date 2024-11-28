// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HtmlView",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HtmlView",
            targets: ["HtmlView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher", exact: "8.1.1"),
        .package(url: "https://github.com/scinfu/SwiftSoup", exact: "2.7.5"),
        .package(url: "https://github.com/exyte/SVGView", exact: "1.0.6")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HtmlView",
            dependencies: ["Kingfisher", "SwiftSoup", "SVGView"]
        ),
        .testTarget(
            name: "HtmlViewTests",
            dependencies: ["HtmlView"]),
    ]
)
