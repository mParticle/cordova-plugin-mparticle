# mParticle Cordova SDK

Cordova plugin for mParticle

[![npm version](https://badge.fury.io/js/cordova-plugin-mparticle.svg)](https://badge.fury.io/js/cordova-plugin-mparticle)
[![Standard - JavaScript Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](http://standardjs.com/)

# Installation

```bash
cordova plugin add @mparticle/cordova-sdk
```

**Grab your mParticle key and secret** from [your app's dashboard][1] and move on to the OS-specific instructions below.

[1]: https://app.mparticle.com/setup/inputs/apps

## iOS

**Install the SDK** using CocoaPods:

```bash
$ # Update your Podfile to depend on 'mParticle-Apple-SDK' version 9.0 or later
$ pod install
```

The mParticle SDK is initialized by calling the `startWithOptions` method within the `application:didFinishLaunchingWithOptions:` delegate call. Preferably the location of the initialization method call should be one of the last statements in the `application:didFinishLaunchingWithOptions:`. The `startWithOptions` method requires an options argument containing your key and secret and an initial Identity request.

> Note that it is imperative for the SDK to be initialized in the `application:didFinishLaunchingWithOptions:` method. Other parts of the SDK rely on the `UIApplicationDidBecomeActiveNotification` notification to function properly. Failing to start the SDK as indicated will impair it. Also, please do **not** use _GCD_'s `dispatch_async` to start the SDK.

#### Swift

```swift
import mParticle_Apple_SDK

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

// Override point for customization after application launch.
let mParticleOptions = MParticleOptions(key: "<<<App Key Here>>>", secret: "<<<App Secret Here>>>")

//Please see the Identity page for more information on building this object
let request = MPIdentityApiRequest()
request.email = "email@example.com"
mParticleOptions.identifyRequest = request
mParticleOptions.onIdentifyComplete = { (apiResult, error) in
    NSLog("Identify complete. userId = %@ error = %@", apiResult?.user.userId.stringValue ?? "Null User ID", error?.localizedDescription ?? "No Error Available")
}

//Start the SDK
MParticle.sharedInstance().start(with: mParticleOptions)

return true
}
```

#### Objective-C

For apps supporting iOS 8 and above, Apple recommends using the import syntax for **modules** or **semantic import**. However, if you prefer the traditional CocoaPods and static libraries delivery mechanism, that is fully supported as well.

If you are using mParticle as a framework, your import statement will be as follows:

```objective-c
@import mParticle_Apple_SDK;                // Apple recommended syntax, but requires "Enable Modules (C and Objective-C)" in pbxproj
#import <mParticle_Apple_SDK/mParticle.h>   // Works when modules are not enabled

```

Otherwise, for CocoaPods without `use_frameworks!`, you can use either of these statements:

```objective-c
#import <mParticle-Apple-SDK/mParticle.h>
#import "mParticle.h"
```

Next, you'll need to start the SDK:

```objective-c
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    MParticleOptions *mParticleOptions = [MParticleOptions optionsWithKey:@"REPLACE ME"
    secret:@"REPLACE ME"];

    //Please see the Identity page for more information on building this object
    MPIdentityApiRequest *request = [MPIdentityApiRequest requestWithEmptyUser];
    request.email = @"email@example.com";
    mParticleOptions.identifyRequest = request;
    mParticleOptions.onIdentifyComplete = ^(MPIdentityApiResult * _Nullable apiResult, NSError * _Nullable error) {
        NSLog(@"Identify complete. userId = %@ error = %@", apiResult.user.userId, error);
    };

    [[MParticle sharedInstance] startWithOptions:mParticleOptions];

    return YES;
}
```

Please see [Identity](http://docs.mparticle.com/developers/sdk/ios/identity/) for more information on supplying an `MPIdentityApiRequest` object during SDK initialization.


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
            .credentials("REPLACE ME WITH KEY", "REPLACE ME WITH SECRET")
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

Add the Rokt kit with the Cordova CLI:

```bash
cordova plugin add @mparticle/cordova-rokt-kit
```

Or declare it in your `config.xml`:

```xml
<plugin name="@mparticle/cordova-rokt-kit" spec="~> 3.0" />
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

### Shoppable Ads

Shoppable Ads enable post-purchase upsell offers with instant checkout. Currently supported on **iOS only**.

#### 1. Add the payment extension

With the Cordova CLI:

```bash
cordova plugin add @mparticle/cordova-rokt-payment-extension
```

Or declare it in your `config.xml`:

```xml
<plugin name="@mparticle/cordova-rokt-payment-extension" spec="^3.0.0" />
```

#### 2. Register the payment extension

The `RoktPaymentExtension` must be registered in your native iOS code after SDK initialization and before calling `selectShoppableAds`.

Since `RoktPaymentExtension` is Swift-only, ObjC apps need a bridging class. See `example/platform_overrides/ios/RoktPaymentSetup.swift` for the wrapper, then call from your AppDelegate:

```objc
#import "YourApp-Swift.h"

[RoktPaymentSetup registerPaymentExtensionWithMerchantId:@"merchant.com.yourapp.rokt"];
```

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

# License

Apache 2.0
