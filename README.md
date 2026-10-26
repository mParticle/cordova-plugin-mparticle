# mParticle Cordova SDK

Cordova plugin for mParticle

[![npm version](https://badge.fury.io/js/cordova-plugin-mparticle.svg)](https://badge.fury.io/js/cordova-plugin-mparticle)
[![Standard - JavaScript Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](http://standardjs.com/)

## Native SDK versions

This release targets the following native SDKs:

| Platform | Dependency | Version |
| --- | --- | --- |
| iOS | [`mparticle-apple-sdk`](https://github.com/mParticle/mparticle-apple-sdk) Swift package | `9.3.0` up to, not including, `10.0.0` |
| Android | `com.mparticle:android-core` | `6.0.0` ([release](https://github.com/mParticle/mparticle-android-sdk/releases/tag/6.0.0)) |

When using Rokt, also install `@mparticle/cordova-rokt-kit`, which adds the [`mp-apple-integration-rokt`](https://github.com/mparticle-integrations/mp-apple-integration-rokt) Swift package (`9.3.0` up to `10.0.0`) on iOS and `com.mparticle:android-rokt-kit:6.0.0` on Android. On Android, the core plugin compiles against the Rokt kit via `compileOnly` and guards Rokt APIs at runtime — apps without the kit build successfully, and Rokt method calls return an error until the kit is installed.

# Installation

```bash
cordova plugin add @mparticle/cordova-sdk
```

**Grab your mParticle key and secret** from [your app's dashboard][1] and move on to the OS-specific instructions below.

[1]: https://app.mparticle.com/setup/inputs/apps

## iOS

The plugin and the mParticle SDK are Swift packages. This needs cordova-ios 8 or later, and no CocoaPods: cordova-ios adds the plugin and the mParticle Swift package to the Xcode project for you. Projects on cordova-ios 7 or earlier need version 4.x of the plugins: see [MIGRATING.md](MIGRATING.md#staying-on-cocoapods).

**Set the deployment target** to iOS 15 or later in `config.xml`, before you add the iOS platform:

```xml
<platform name="ios">
    <preference name="deployment-target" value="15.0" />
</platform>
```

```bash
cordova platform add ios@8
```

The mParticle SDK is initialized by calling the `start(with:)` method within the `application(_:didFinishLaunchingWithOptions:)` delegate call. Preferably the location of the initialization method call should be one of the last statements in `application(_:didFinishLaunchingWithOptions:)`. The `start(with:)` method requires an options argument containing your key and secret and an initial Identity request.

> Note that it is imperative for the SDK to be initialized in the `application(_:didFinishLaunchingWithOptions:)` method. Other parts of the SDK rely on the `UIApplicationDidBecomeActiveNotification` notification to function properly. Failing to start the SDK as indicated will impair it. Also, please do **not** use _GCD_'s `dispatch_async` to start the SDK.

cordova-ios 8 generates `platforms/ios/App/AppDelegate.swift`. Add the start-up code to it. Cordova regenerates `platforms/`, so keep your copy outside it and copy it in with an `after_prepare` hook, as the [example app](example/hooks/after_prepare/010_copy_platform_specific_files.js) does with [`AppDelegate.swift`](example/platform_overrides/ios/AppDelegate.swift). This reapplies your changes before each build or run.

```swift
import UIKit
import mParticle_Apple_SDK

@main
#if compiler(>=6.1)
@objc @implementation
#else
@_objcImplementation
#endif
extension AppDelegate {
    open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let mParticleOptions = MParticleOptions(key: "<<<App Key Here>>>", secret: "<<<App Secret Here>>>")

        //Please see the Identity page for more information on building this object
        let request = MPIdentityApiRequest.withEmptyUser()
        request.email = "email@example.com"
        mParticleOptions.identifyRequest = request
        mParticleOptions.onIdentifyComplete = { (apiResult, error) in
            NSLog("Identify complete. userId = %@ error = %@", apiResult?.user.userId.stringValue ?? "Null User ID", error?.localizedDescription ?? "No Error Available")
        }

        //Start the SDK
        MParticle.sharedInstance().start(with: mParticleOptions)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Keep the rest of the generated AppDelegate, such as application(_:configurationForConnecting:options:).
}
```

Routing the Rokt SDK+ through your own domain reduces the risk of ad blockers and browsers from blocking ads or data. You can configure this with `MPNetworkOptions`:

```swift
let networkOptions = MPNetworkOptions()
networkOptions.customBaseURL = URL(string: "https://rkt.example.com")
mParticleOptions.networkOptions = networkOptions
```

Please see [Identity](http://docs.mparticle.com/developers/sdk/ios/identity/) for more information on supplying an `MPIdentityApiRequest` object during SDK initialization.

**Other mParticle kits:** cordova-ios 8 links only the Swift packages that plugins declare. To add another kit, wrap its Swift package in a small local plugin with its own `Package.swift`, as [`Kits/Rokt`](Kits/Rokt) does: see [MIGRATING.md](MIGRATING.md#other-mparticle-kits).

### Upgrading from 4.x

Version 5 takes the iOS SDKs from Swift Package Manager instead of CocoaPods, and needs cordova-ios 8. See [MIGRATING.md](MIGRATING.md) for the steps.

## Android

1. Grab your mParticle key and secret from [your workspace's dashboard](https://app.mparticle.com/setup/inputs/apps) and construct an `MParticleOptions` object.

2. Call `start` from the `onCreate` method of your app's `Application` class. It's crucial that the SDK be started here for proper session management. If you don't already have an `Application` class, create it and then specify its fully-qualified name in the `<application>` tag of your app's `AndroidManifest.xml`.

```kotlin
package com.example.myapp;

import android.app.Application;
import com.mparticle.MParticle;

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        val options: MParticleOptions = MParticleOptions.builder(this)
            .credentials("REPLACE_ME_WITH_KEY", "REPLACE_ME_WITH_SECRET")
            .logLevel(MParticle.LogLevel.VERBOSE)
            .identify(identifyRequest)
            .identifyTask(
                BaseIdentityTask()
                    .addFailureListener() { response -> }
                    .addSuccessListener { result -> }
            )
            .build()
        MParticle.start(options)
    }
}
```

Routing the Rokt SDK+ through your own domain reduces the risk of ad blockers and browsers from blocking ads or data. You can configure this with `NetworkOptions`:

```java
import com.mparticle.networking.NetworkOptions;

MParticleOptions options = MParticleOptions.builder(this)
    .credentials("REPLACE_ME_WITH_KEY", "REPLACE_ME_WITH_SECRET")
    .networkOptions(NetworkOptions.withNetworkOptions("https://rkt.example.com"))
    .build();
```

```kotlin
import com.mparticle.networking.NetworkOptions

val options = MParticleOptions.builder(this)
    .credentials("REPLACE_ME_WITH_KEY", "REPLACE_ME_WITH_SECRET")
    .networkOptions(NetworkOptions.withNetworkOptions("https://rkt.example.com"))
    .build()
```

> **Warning:** It's generally not a good idea to log events in your `Application.onCreate()`. Android may instantiate your `Application` class for a lot of reasons, in the background, while the user isn't even using their device.


# Usage

## Events

**Logging** events:

```js
mparticle.logEvent('Test event', mparticle.EventType.Other, { 'Test key': 'Test value' })
```

**Logging** commerce events:

```js
var product = new mparticle.Product('Test product for cart', 1234, 19.99)
var transactionAttributes = new mparticle.TransactionAttributes('Test transaction id')
var event = mparticle.CommerceEvent.createProductActionEvent(mparticle.ProductActionType.AddToCart, [product], transactionAttributes)

mparticle.logCommerceEvent(event)
```

```js
var promotion = new mparticle.Promotion('Test promotion id', 'Test promotion name', 'Test creative', 'Test position')
var event = mparticle.CommerceEvent.createPromotionEvent(mparticle.PromotionActionType.View, [promotion])

mparticle.logCommerceEvent(event)
```

```js
var product = new mparticle.Product('Test viewed product', 5678, 29.99)
var impression = new mparticle.Impression('Test impression list name', [product])
var event = mparticle.CommerceEvent.createImpressionEvent([impression])

mparticle.logCommerceEvent(event)
```

**Logging** screen events:

```js
mparticle.logScreenEvent('Test screen', { 'Test key': 'Test value' })
```

## User
**Setting** user attributes and tags:

Use Identify or currentUser to retrieve the userID for these calls
```js
var user = new mparticle.User('userID');
```

```js
user.setUserAttribute(mparticle.UserAttributeType.FirstName, 'Test first name');
```

```js
user.setUserAttributeArray(mparticle.UserAttributeType.FirstName, ['Test value 1', 'Test value 2']);
```

```js
user.setUserTag('Test value');
```

```js
user.removeUserAttribute(mparticle.UserAttributeType.FirstName);
```

```js
user.getUserIdentities((userIdentities) => {
    console.debug(userIdentities);
});
```

## IdentityRequest

```js
var request = new MParticle.IdentityRequest();
```

**Setting** user identities:

```js
var request = new MParticle.IdentityRequest();
request.setUserIdentity('example@example.com', MParticle.UserIdentityType.Email);
```

## Identity

```js
MParticle.Identity.getCurrentUser(function (userID) => {
    console.debug(userID);
});
```

**Using** static methods to update and change identity


```js
var request = new mparticle.IdentityRequest();

var identity = new mparticle.Identity();
identity.identify(request, function (userId) => {
    console.debug(userId);
});
```

```js
var request = new mparticle.IdentityRequest();
request.email = 'test email';

var identity = new mparticle.Identity();
identity.login(request, function (userId) => {
    console.debug(userId);
});
```

```js
var request = new mparticle.IdentityRequest();

var identity = new mparticle.Identity();
identity.logout(request, function (userId) => {
    console.debug(userId);
});
```

```js
var request = new MParticle.IdentityRequest();
request.email = 'test email 2';

var identity = new mparticle.Identity();
identity.modify(request, function (userId) => {
    console.debug(userId);
});
```

## Rokt

### Installation

Add the Rokt kit to your `config.xml`:

```xml
<plugin name="@mparticle/cordova-rokt-kit" spec="~> 5.0" />
```

### Select Placements

Display a Rokt overlay placement on your confirmation or thank-you page:

```js
var attributes = {
    'email': 'j.smith@example.com',
    'firstname': 'Jenny',
    'lastname': 'Smith',
    'confirmationref': '54321',
    'country': 'US'
};

mparticle.Rokt.selectPlacements('YourPlacementIdentifier', attributes);
```

You can optionally pass a configuration object:

```js
var config = {
    colorMode: mparticle.Rokt.ColorMode.SYSTEM,  // LIGHT, DARK, or SYSTEM
    cacheConfig: {
        cacheDurationInSeconds: 5400,
        cacheAttributes: {}
    }
};

mparticle.Rokt.selectPlacements('YourPlacementIdentifier', attributes, config);
```

### Placement Events

Subscribe to lifecycle and engagement events for a specific placement. The callback fires every time the SDK emits an event for the given identifier — call once after `deviceready` and keep the subscription alive for the lifetime of your view.

```js
mparticle.Rokt.events('YourPlacementIdentifier', function (event) {
    switch (event.event) {
        case mparticle.Rokt.EventType.PlacementInteractive:
            // placement rendered and is interactable
            break;
        case mparticle.Rokt.EventType.OfferEngagement:
        case mparticle.Rokt.EventType.PositiveEngagement:
            // user engaged with the offer
            break;
        case mparticle.Rokt.EventType.PlacementClosed:
        case mparticle.Rokt.EventType.PlacementCompleted:
        case mparticle.Rokt.EventType.PlacementFailure:
            // placement finished — show your next-page content
            break;
    }
});
```

Each event delivered to your callback is an object with an `event` discriminator string plus event-specific fields. Cross-platform event types:

| Event | Fields | Notes |
| --- | --- | --- |
| `ShowLoadingIndicator` | — | About to call the Rokt backend. |
| `HideLoadingIndicator` | — | Backend responded (success or failure). |
| `InitComplete` | `success` | SDK finished initialization. |
| `PlacementReady` | `placementId` | Placement ready but not yet rendered. |
| `PlacementInteractive` | `placementId` | Rendered and ready for user interaction. |
| `PlacementClosed` | `placementId` | User dismissed the placement. |
| `PlacementCompleted` | `placementId` | No more offers to display. |
| `PlacementFailure` | `placementId` (nullable) | Could not be displayed. |
| `OfferEngagement` | `placementId` | User engaged with an offer. |
| `PositiveEngagement` | `placementId` | User accepted an offer. |
| `FirstPositiveEngagement` | `placementId` | First positive engagement in the session. |
| `OpenUrl` | `placementId`, `url` | Passthrough link requested. |
| `CartItemInstantPurchase` | `placementId`, `cartItemId`, `catalogItemId`, `currency`, `description`, `linkedProductId`, `totalPrice`, `quantity`, `unitPrice` | Shoppable Ads purchase completed. |

The following event types are **iOS only** (not yet emitted by the Android Rokt SDK):

| Event | Fields |
| --- | --- |
| `EmbeddedSizeChanged` | `placementId`, `updatedHeight` |
| `CartItemInstantPurchaseInitiated` | `placementId`, `cartItemId`, `catalogItemId` |
| `CartItemInstantPurchaseFailure` | `placementId`, `cartItemId`, `catalogItemId`, `error` |
| `InstantPurchaseDismissal` | `placementId` |
| `CartItemDevicePay` | `placementId`, `cartItemId`, `catalogItemId`, `paymentProvider` |

### Shoppable Ads

Shoppable Ads enable post-purchase upsell offers with instant checkout (Apple Pay, AfterPay/Clearpay, PayPal via Stripe). `selectShoppableAds` and `purchaseFinalized` are supported on **both iOS and Android** when using `@mparticle/cordova-rokt-kit` with native SDK 6.0.0 / 9.x.

Payment extension registration for Apple Pay / AfterPay / PayPal remains **iOS-only** via `@mparticle/cordova-rokt-payment-extension`. Register the extension natively on Android if your integration requires it.

#### 1. Add the payment extension kit (iOS)

```xml
<plugin name="@mparticle/cordova-rokt-payment-extension" spec="~> 5.0" />
```

This adds the [`rokt-payment-extension-ios`](https://github.com/ROKT/rokt-payment-extension-ios) Swift package (`2.0.0` up to `3.0.0`) to your iOS app. There is no Cordova artefact for Android payment extension registration.

#### 2. Register the payment extension from your AppDelegate (iOS)

Register the extension in `AppDelegate.swift`, after starting the SDK. See [`example/platform_overrides/ios/AppDelegate.swift`](example/platform_overrides/ios/AppDelegate.swift) for the working example:

```swift
import RoktPaymentExtension

// In application(_:didFinishLaunchingWithOptions:), after MParticle.sharedInstance().start(with:)
if let paymentExtension = RoktPaymentExtension(applePayMerchantId: "merchant.com.yourapp.rokt") {
    MParticle.sharedInstance().rokt.registerPaymentExtension(paymentExtension)
}
```

The Rokt kit on mParticle Apple SDK 9.x reads `stripePublishableKey` from kit configuration in the mParticle dashboard and forwards it to Rokt as `stripeKey` at registration time — the host only supplies the Apple Pay merchant identifier above.

#### 3. Display Shoppable Ads

```js
var attributes = {
    'email': 'j.smith@example.com',
    'firstname': 'Jenny',
    'lastname': 'Smith',
    'confirmationref': 'ORD-8829-XK2',
    'amount': '52.25',
    'currency': 'USD',
    'paymenttype': 'visa',
    'shippingaddress1': '123 Main St',
    'shippingcity': 'Brooklyn',
    'shippingstate': 'NY',
    'shippingzipcode': '11201',
    'shippingcountry': 'US'
};

mparticle.Rokt.selectShoppableAds('YourPlacementIdentifier', attributes);
```

#### 4. Handle redirect-based payment callbacks (AfterPay, PayPal)

For payment methods that bounce out to a web flow and return via a custom URL scheme, forward the callback into Rokt. cordova-ios 8 apps use scenes, so URLs arrive at the scene delegate rather than `application(_:open:options:)`. Override it in `platforms/ios/App/SceneDelegate.swift`, copied in the same way as `AppDelegate.swift`:

```swift
import Cordova
import mParticle_Apple_SDK

class SceneDelegate: CDVSceneDelegate {
    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            _ = MParticle.sharedInstance().rokt.handleURLCallback(with: context.url)
        }
        // Lets Cordova plugins handle the URL too.
        super.scene(scene, openURLContexts: URLContexts)
    }
}
```

Or from JS (when the host has already received the URL and just wants to hand it off):

```js
mparticle.Rokt.handleURLCallback(urlString, function (handled) {
    if (!handled) {
        // route the URL via your own deep-link handler
    }
});
```

`handleURLCallback` is iOS-only; the Android bridge resolves to `false`.

#### 5. Session continuity with WebViews (optional)

If you have a WebView leg of the same flow and want it to share the Rokt session:

```js
mparticle.Rokt.getSessionId(function (sessionId) {
    // pass sessionId into your WebView URL / postMessage
});

// or, when starting a native flow with a session from elsewhere:
mparticle.Rokt.setSessionId('your-session-id');
```

# License

Apache 2.0
