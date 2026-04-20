#!/usr/bin/env node

var fs = require('fs');
var path = require('path');
var shell = require('child_process');

module.exports = function(context) {
    // Get platform from context
    var platform = context.opts.platforms[0];

    function ensureDirectoryExistence(filePath) {
        var dirname = path.dirname(filePath);
        if (fs.existsSync(dirname)) {
            return true;
        }
        fs.mkdirSync(dirname, { recursive: true });
    }

    function copyFile(srcRelative, destRelative, label) {
        var src = path.join(context.opts.projectRoot, srcRelative);
        var dest = path.join(context.opts.projectRoot, destRelative);
        if (fs.existsSync(src)) {
            try {
                ensureDirectoryExistence(dest);
                fs.copyFileSync(src, dest);
                console.log('Copied ' + label);
            } catch (err) {
                console.error('Error copying ' + label + ':', err);
                process.exitCode = 1;
            }
        }
    }

    if (platform === 'android') {
        copyFile(
            path.join('platform_overrides', 'android', 'MainActivity.java'),
            path.join('platforms', 'android', 'app', 'src', 'main', 'java', 'com', 'mparticle', 'example', 'MainActivity.java'),
            'custom MainActivity.java'
        );
    } else if (platform === 'ios') {
        // Replace ObjC AppDelegate with Swift version
        var objcAppDelegate = path.join(context.opts.projectRoot, 'platforms', 'ios', 'MParticleExample', 'AppDelegate.m');
        if (fs.existsSync(objcAppDelegate)) {
            fs.unlinkSync(objcAppDelegate);
            console.log('Removed ObjC AppDelegate.m');
        }
        var objcAppDelegateHeader = path.join(context.opts.projectRoot, 'platforms', 'ios', 'MParticleExample', 'AppDelegate.h');
        if (fs.existsSync(objcAppDelegateHeader)) {
            fs.unlinkSync(objcAppDelegateHeader);
            console.log('Removed ObjC AppDelegate.h');
        }

        copyFile(
            path.join('platform_overrides', 'ios', 'AppDelegate.swift'),
            path.join('platforms', 'ios', 'MParticleExample', 'AppDelegate.swift'),
            'custom AppDelegate.swift'
        );

        // Replace main.m to remove AppDelegate.h import
        copyFile(
            path.join('platform_overrides', 'ios', 'main.m'),
            path.join('platforms', 'ios', 'MParticleExample', 'main.m'),
            'custom main.m'
        );

        // Configure Xcode project for Swift AppDelegate
        var iosPath = path.join(context.opts.projectRoot, 'platforms', 'ios');
        var configureXcodeScript = path.join(context.opts.projectRoot, 'hooks', 'after_platform_add', 'configure_xcode_swift.rb');
        try {
            shell.execSync('cd ' + iosPath + ' && ruby ' + configureXcodeScript, { stdio: 'inherit' });
        } catch (err) {
            console.error('Error configuring Xcode project for Swift:', err);
            process.exitCode = 1;
        }
    }
};
