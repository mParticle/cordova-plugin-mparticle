# Migration Guides

This document provides migration guidance for changes in the mParticle Cordova plugins: `@mparticle/cordova-sdk`, `@mparticle/cordova-rokt-kit` and `@mparticle/cordova-rokt-payment-extension`.

## 5.0: the iOS SDKs now come from Swift Package Manager

**Breaking, iOS only.** The three plugins are now Swift packages. The mParticle Apple SDK, the Rokt kit and the Rokt payment extension come from Swift Package Manager instead of CocoaPods, because CocoaPods trunk becomes read-only on 2 December 2026. iOS needs cordova-ios 8 or later, and CocoaPods is no longer used: no Podfile is generated. Android code is unchanged, but 5.0 needs Cordova CLI 12 or later on every platform.

The native version ranges are the same as the 4.x pods:

| Plugin | 4.x CocoaPod | 5.0 Swift package |
| --- | --- | --- |
| `@mparticle/cordova-sdk` | `mParticle-Apple-SDK ~> 9.3` | [`mparticle-apple-sdk`](https://github.com/mParticle/mparticle-apple-sdk), `9.3.0` up to `10.0.0` |
| `@mparticle/cordova-rokt-kit` | `mParticle-Rokt ~> 9.3` | [`mp-apple-integration-rokt`](https://github.com/mparticle-integrations/mp-apple-integration-rokt), `9.3.0` up to `10.0.0` |
| `@mparticle/cordova-rokt-payment-extension` | `RoktPaymentExtension ~> 2.0` | [`rokt-payment-extension-ios`](https://github.com/ROKT/rokt-payment-extension-ios), `2.0.0` up to `3.0.0` |

### Upgrade steps

1. Move to Cordova CLI 12 or later and cordova-ios 8. cordova-ios 8 needs Node.js 20.17 or later in the 20.x line, or 22.9 or later, and Xcode 15 or later.
2. In `config.xml`, set the deployment target to iOS 15 or later:

   ```xml
   <platform name="ios">
       <preference name="deployment-target" value="15.0" />
   </platform>
   ```

   Set it before you add the platform in step 5. cordova-ios 8.1.1 and earlier apply it to the plugins' Swift package only when the platform is added.
3. Upgrade all three plugins to 5.x together. A 4.x kit next to the 5.x core still adds its CocoaPod, which brings a second copy of the mParticle SDK into the app: it builds, then fails at runtime.
4. For the same reason, remove any mParticle or Rokt pods you added yourself, for example in a custom plugin's `<podspec>`.
5. Re-create the iOS platform:

   ```bash
   cordova platform rm ios
   cordova platform add ios@8
   ```

   cordova-ios 8 names the Xcode project and target `App` (`platforms/ios/App.xcodeproj`, `platforms/ios/App/`) instead of your app's name. Update any hooks or scripts that find them by name.
6. Move the SDK start-up into the Swift `AppDelegate.swift` that cordova-ios 8 generates, and import the SDK with `import mParticle_Apple_SDK`. See [README › iOS](README.md#ios) for the code. Cordova regenerates `platforms/`, so keep your copy outside it and copy it in with an `after_prepare` hook, as the [example app](example/hooks/after_prepare/010_copy_platform_specific_files.js) does.
7. If you use the payment extension, delete the Swift shim (`RoktPaymentSetup.swift` in the 4.x example) and its bridging header, and register the extension in `AppDelegate.swift`, after starting the SDK. The Swift method is `registerPaymentExtension(_:)`:

   ```swift
   import RoktPaymentExtension

   if let paymentExtension = RoktPaymentExtension(applePayMerchantId: "merchant.com.yourapp.rokt") {
       MParticle.sharedInstance().rokt.registerPaymentExtension(paymentExtension)
   }
   ```

8. If you forward payment redirect URLs to Rokt in `application:openURL:options:`, move that code to a `SceneDelegate` override. cordova-ios 8 apps use scenes, so the app delegate no longer receives URLs. See [README › Handle redirect-based payment callbacks](README.md#4-handle-redirect-based-payment-callbacks-afterpay-paypal).
9. Build and run once. `platforms/ios` should have no `Podfile`, and with `logLevel` set to verbose the log shows `Included kits: {Rokt}` when the Rokt kit is installed.

### Other mParticle kits

cordova-ios 8 links only the Swift packages that plugins declare, so a kit pod you added another way is no longer installed. Wrap the kit's Swift package in a small local plugin by copying [`Kits/Rokt`](Kits/Rokt), then:

1. Change the plugin id in `plugin.xml`, `package.json` and `Package.swift`. In `Package.swift`, the package name and the library product name must both equal the plugin id.
2. Rename the target in `Package.swift`, and the stub file in `src/ios` to match. Target names must be unique across all of the app's packages, so a copy that keeps `MParticleCordovaRoktKit` fails to resolve next to the Rokt kit.
3. Change the package URL and product to the kit's. The [mParticle Apple SDK README](https://github.com/mParticle/mparticle-apple-sdk#readme) lists each kit's Swift package. Choose a kit version that supports mParticle Apple SDK 9, or Swift Package Manager cannot resolve the packages.

### Capacitor

Capacitor reads a Cordova plugin's `Package.swift` from Capacitor 8.3.2, in apps that use Swift Package Manager. Capacitor apps that use CocoaPods get no iOS code from 5.0 and should stay on 4.x. We have not tested 5.0 with Capacitor.

### Staying on CocoaPods

Keep cordova-ios 7 and the 4.x plugins, and pin them, for example `cordova plugin add @mparticle/cordova-sdk@4`, or `spec="~> 4.1"` in `config.xml`. An unpinned `cordova plugin add` falls back to 4.x by itself only when the iOS platform is already added and no plugin version is saved in `package.json` or `config.xml`. No new pod versions can be published after 2 December 2026, so 4.x stays on the last mParticle SDK released to CocoaPods.
