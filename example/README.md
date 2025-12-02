# MParticle Cordova Example

This example demonstrates how to integrate the MParticle Cordova plugin into your application.

## Prerequisites

- Node.js and npm
- Cordova CLI
- Xcode (for iOS development)
- Android Studio (for Android development)

## Setup

1. Install dependencies:
```bash
npm install
```

2. Add your MParticle credentials:
   - In `platform_overrides/android/MainActivity.java`, replace:
     - `REPLACE_ME_API_KEY` with your Android API key
     - `REPLACE_ME_API_SECRET` with your Android API secret
   
   - In `platform_overrides/ios/AppDelegate.m`, replace:
     - `REPLACE_ME_API_KEY` with your iOS API key
     - `REPLACE_ME_API_SECRET` with your iOS API secret

3. (Optional) Add mParticle kit dependencies:
   
   Install kit plugins to add native dependencies. For example, to add the Rokt kit:
   
   ```bash
   cordova plugin add ../Kits/Rokt
   ```
   
   Or add it directly in `config.xml`:
   ```xml
   <plugin name="cordova-plugin-mparticle-kits-rokt" spec="../Kits/Rokt" />
   ```

4. Add platforms:
```bash
cordova platform add android
cordova platform add ios
```

## Running the App

For Android:
```bash
cordova run android
```

For iOS:
```bash
cordova run ios
```

## Development

The example includes a clean script to help reset the project state:

```bash
npm run clean
```

This will:
- Remove the platforms directory
- Remove the plugins directory
- Remove node_modules and package-lock.json
- Reinstall dependencies

After cleaning, you'll need to re-add the platforms:
```bash
cordova platform add android ios
```

## Project Structure

- `platform_overrides/` - Platform-specific files that are automatically copied during platform setup
  - `android/MainActivity.java` - Android app entry point
  - `ios/AppDelegate.m` - iOS app delegate
- `Kits/` - mParticle kit dependency plugins
  - `Rokt/` - Rokt kit plugin (adds native dependencies)
- `www/` - Web assets and Cordova application code
- `hooks/` - Scripts that run during Cordova commands
