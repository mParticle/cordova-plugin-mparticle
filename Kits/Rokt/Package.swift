// swift-tools-version:5.9
// cordova-ios 8 installs this plugin as a Swift package. The package and product name must equal
// the plugin id.

import PackageDescription

let package = Package(
    name: "@mparticle/cordova-rokt-kit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "@mparticle/cordova-rokt-kit", targets: ["MParticleCordovaRoktKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mparticle-integrations/mp-apple-integration-rokt", "9.3.0"..<"10.0.0"),
    ],
    targets: [
        .target(
            name: "MParticleCordovaRoktKit",
            dependencies: [.product(name: "mParticle-Rokt", package: "mp-apple-integration-rokt")],
            path: "src/ios"
        ),
    ]
)
