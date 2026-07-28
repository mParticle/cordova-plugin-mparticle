<!-- markdownlint-disable MD024 -->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Bumped Android native dependencies to `com.mparticle:android-core:6.0.0` and `com.mparticle:android-rokt-kit:6.0.0`.
- Bumped iOS pod specs to `mParticle-Apple-SDK ~> 9.3` and `mParticle-Rokt ~> 9.3`.
- Migrated the Android Rokt bridge for SDK 6.0.0: Rokt moved out of `android-core` into `android-rokt-kit` and `com.rokt.roktsdk` contracts (`MParticleRoktKt.getRokt()`, `com.rokt.roktsdk.RoktEvent`, `com.rokt.roktsdk.RoktConfig`, etc.).
- Android Rokt integration is now optional: the core plugin compiles against `android-rokt-kit` via `compileOnly` and guards Rokt APIs at runtime (`RoktKitAvailability`). Apps without `@mparticle/cordova-rokt-kit` build successfully; Rokt method calls return a clear error until the kit is installed.

### Added

- Android support for `mparticle.Rokt.selectShoppableAds` and `mparticle.Rokt.purchaseFinalized` (previously logged no-ops on Android).

### Fixed

- Android Rokt event serialization updated for SDK 6.0.0 event types (`getIdentifier()` replaces `getPlacementId()`).

### Notes

- `mparticle.Rokt.handleURLCallback` remains iOS-only; Android SDK 6.0.0 does not yet expose an equivalent hook.
- Device-level consent APIs in native SDK 9.3.1 / 6.0.0 are not yet exposed through the Cordova JS bridge.
- `@mparticle/cordova-rokt-payment-extension` remains iOS-only (registers `RoktPaymentExtension` for Apple Pay / AfterPay / PayPal).

## [4.0.1] - 2026-06-12

## [4.0.0] - 2026-06-11

- Bumped Android native dependencies to `com.mparticle:android-core:5.79.0` and `com.mparticle:android-rokt-kit:5.79.0`.
- Bumped iOS pod specs to `mParticle-Apple-SDK ~> 9.2` and `mParticle-Rokt ~> 9.2`.
- Renamed the Stripe-specific payment kit to a unified one: `Kits/RoktStripePayment/` → `Kits/RoktPaymentExtension/`, npm id `@mparticle/cordova-rokt-stripe-payment-kit` → `@mparticle/cordova-rokt-payment-extension`, pod `RoktStripePaymentExtension ~> 0.1` → `RoktPaymentExtension ~> 2.0`. The new pod internally routes to Stripe for Apple Pay / card / AfterPay / Clearpay / PayPal.
- Example app's Swift bridge constructs the unified `RoktPaymentExtension(applePayMerchantId:)` instead of `RoktStripePaymentExtension`. The Rokt kit now reads `stripePublishableKey` from mParticle dashboard configuration, so partners no longer need to thread `stripeKey` through JS.

### Added

- `mparticle.Rokt.setSessionId(sessionId)` / `mparticle.Rokt.getSessionId(completion)` — bridged to `MPRokt.setSessionId:` / `-getSessionId` on iOS and `MParticle.getInstance().Rokt().setSessionId / .getSessionId` on Android. Useful for keeping the native and WebView legs of a flow on the same Rokt session.
- `mparticle.Rokt.handleURLCallback(url, completion)` — bridged to `[MPRokt handleURLCallback:]` on iOS so the host AppDelegate can hand redirect-based payment callbacks (AfterPay, PayPal) back to the registered Rokt payment extension. Android is a silent no-op that resolves to `false`.
- README examples for configuring a custom CNAME endpoint on iOS (`MPNetworkOptions.customBaseURL`) and Android (`NetworkOptions.withNetworkOptions`).

## [3.0.1] - 2026-05-27

### Fixed

- Adjusted range upper bound to prevent next major pull ([0a1d968](https://github.com/mParticle/cordova-plugin-mparticle/commit/0a1d968a19d7a87f615d85444d146588883662b9))

## [3.0.0] - 2026-01-13

### Added

- Added support for Rokt Kit plugin

## [2.2.4] - 2023-03-14

### Fixed

- Setting GDPR Consents on iOS ([#23](https://github.com/mParticle/cordova-plugin-mparticle/issues/23)) ([c13eaa7](https://github.com/mParticle/cordova-plugin-mparticle/commit/c13eaa7f3e68fb3a510de75c25831c44ce716dc9))

## [2.2.3] - 2023-01-09

### Fixed

- Android Consent now retains previously Set Consent States ([#22](https://github.com/mParticle/cordova-plugin-mparticle/issues/22)) ([c5ce970](https://github.com/mParticle/cordova-plugin-mparticle/commit/c5ce97014b9cefc86c878f899472848c1d3fa6f7))

## [2.2.2] - 2022-09-29

### Fixed

- Fix ProductActions getting mapped to PromotionActions ([#16](https://github.com/mParticle/cordova-plugin-mparticle/issues/16)) ([85ab4c7](https://github.com/mParticle/cordova-plugin-mparticle/commit/85ab4c7c67a16e93879e8488760baeec3abda650))

## [2.2.1] - 2022-05-19

### Fixed

- Update Android usage of info -> customAttributes ([#15](https://github.com/mParticle/cordova-plugin-mparticle/issues/15)) ([dc8830b](https://github.com/mParticle/cordova-plugin-mparticle/commit/dc8830b05ff8ae4401c3c731eb023cb3f4dfa200))

## [2.2.0] - 2022-05-06

### Changed

- Update MParticle Android SDK to 5.38.1 ([05e3e5d](https://github.com/mParticle/cordova-plugin-mparticle/commit/05e3e5db7cecc01cf6a74bb8b10ef141dfc22c7c))

## [2.1.0] - 2022-05-06

### Added

- Add GDPR and CCPA Consent ([#13](https://github.com/mParticle/cordova-plugin-mparticle/issues/13)) ([60368be](https://github.com/mParticle/cordova-plugin-mparticle/commit/60368be9d9ec8f471bc8d5a7b479ed0ce7d9f05e))

[unreleased]: https://github.com/mParticle/cordova-plugin-mparticle/compare/4.0.1...HEAD
[4.0.1]: https://github.com/mParticle/cordova-plugin-mparticle/compare/4.0.0...4.0.1
[4.0.0]: https://github.com/mParticle/cordova-plugin-mparticle/compare/3.0.1...4.0.0
[3.0.1]: https://github.com/mParticle/cordova-plugin-mparticle/compare/3.0.0...3.0.1
[3.0.0]: https://github.com/mParticle/cordova-plugin-mparticle/compare/2.2.4...3.0.0
[2.2.4]: https://github.com/mParticle/cordova-plugin-mparticle/compare/2.2.3...2.2.4
[2.2.3]: https://github.com/mParticle/cordova-plugin-mparticle/compare/2.2.2...2.2.3
[2.2.2]: https://github.com/mParticle/cordova-plugin-mparticle/compare/2.2.1...2.2.2
[2.2.1]: https://github.com/mParticle/cordova-plugin-mparticle/compare/2.2.0...2.2.1
[2.2.0]: https://github.com/mParticle/cordova-plugin-mparticle/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/mParticle/cordova-plugin-mparticle/compare/2.0.6...2.1.0
