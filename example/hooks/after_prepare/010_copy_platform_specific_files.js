#!/usr/bin/env node

var fs = require('fs');
var path = require('path');

module.exports = function(context) {
    var platforms = context.opts.platforms;

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

    if (platforms.includes('android')) {
        copyFile(
            path.join('platform_overrides', 'android', 'MainActivity.java'),
            path.join('platforms', 'android', 'app', 'src', 'main', 'java', 'com', 'mparticle', 'example', 'MainActivity.java'),
            'custom MainActivity.java'
        );
    }

    if (platforms.includes('ios')) {
        // Replaces the cordova-ios 8 template's AppDelegate.swift, which is already in the Xcode
        // project. The mParticle and Rokt Swift packages come from the plugins in config.xml.
        copyFile(
            path.join('platform_overrides', 'ios', 'AppDelegate.swift'),
            path.join('platforms', 'ios', 'App', 'AppDelegate.swift'),
            'custom AppDelegate.swift'
        );
    }
};
