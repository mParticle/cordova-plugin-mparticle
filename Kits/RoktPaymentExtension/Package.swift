// swift-tools-version:5.9
// cordova-ios 8 installs this plugin as a Swift package. The package and product name must equal
// the plugin id.

import PackageDescription

let package = Package(
    name: "@mparticle/cordova-rokt-payment-extension",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "@mparticle/cordova-rokt-payment-extension", targets: ["MParticleCordovaRoktPaymentExtension"]),
    ],
    dependencies: [
        // RoktPaymentExtension stays on its own 2.x line, as RoktSDKPlus also requires.
        .package(url: "https://github.com/ROKT/rokt-payment-extension-ios.git", "2.0.0"..<"3.0.0"),
    ],
    targets: [
        .target(
            name: "MParticleCordovaRoktPaymentExtension",
            dependencies: [.product(name: "RoktPaymentExtension", package: "rokt-payment-extension-ios")],
            path: "src/ios"
        ),
    ]
)
