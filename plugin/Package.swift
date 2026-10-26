// swift-tools-version:5.9
// cordova-ios 8 installs this plugin as a Swift package. The package and product name must equal
// the plugin id. cordova-ios rewrites the Cordova dependency below to a local path, matching it by
// a single-line regex, so it must stay on one line.

import PackageDescription

let package = Package(
    name: "@mparticle/cordova-sdk",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "@mparticle/cordova-sdk", targets: ["MParticleCordova"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apache/cordova-ios.git", branch: "master"),
        // Same URLs as the mParticle kits use, so SwiftPM unifies them into one package identity.
        .package(url: "https://github.com/mParticle/mparticle-apple-sdk", "9.3.0"..<"10.0.0"),
        .package(url: "https://github.com/ROKT/rokt-contracts-apple.git", "2.0.0"..<"3.0.0"),
    ],
    targets: [
        .target(
            name: "MParticleCordova",
            dependencies: [
                .product(name: "Cordova", package: "cordova-ios"),
                .product(name: "mParticle-Apple-SDK", package: "mparticle-apple-sdk"),
                .product(name: "RoktContracts", package: "rokt-contracts-apple"),
            ],
            path: "src/ios",
            // An Objective-C target needs a public headers path that exists; this plugin has no headers.
            publicHeadersPath: "."
        ),
    ]
)
