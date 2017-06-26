# cordova-plugin-mparticle

Cordova plugin for mParticle

[![npm version](https://badge.fury.io/js/cordova-plugin-mparticle.svg)](https://badge.fury.io/js/cordova-plugin-mparticle)
[![Standard - JavaScript Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](http://standardjs.com/)

# Installation

```bash
cordova plugin add cordova-plugin-mparticle
```

**Grab your mParticle key and secret** from [your app's dashboard][1] and move on to the OS-specific instructions below.

[1]: https://app.mparticle.com/apps

## iOS

**Start mParticle** within `application:didFinishLaunchingWithOptions:`:

```objective-c
[[MParticle sharedInstance] startWithKey:@"APP KEY" secret:@"APP SECRET"];
```

## Android

**Add your key and secret** as string resources in your app:

```xml
<?xml version="1.0" encoding="utf-8" ?>
<!-- ex. src/main/res/values/mparticle.xml -->
<resources>
    <string name="mp_key">APP KEY</string>
    <string name="mp_secret">APP SECRET</string>
</resources>
```

**Start mParticle** in your application's `onCreate`:

```objective-c
MParticle.start(this);
```

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

## User Attributes

**Setting** user attributes and tags:

```js
mparticle.setUserAttribute('Test key', 'Test value')
```

```js
mparticle.setUserAttribute(mparticle.UserAttributeType.FirstName, 'Test first name')
```

```js
mparticle.setUserAttributeArray('Test key', ['Test value 1', 'Test value 2'])
```

```js
mparticle.setUserTag('Test key')
```

```js
mparticle.removeUserAttribute('Test key')
```

## User Identities

**Setting** user identities:

```js
mparticle.setUserIdentity('example@example.com', mparticle.UserIdentityType.Email)
```

# License

Apache 2.0
