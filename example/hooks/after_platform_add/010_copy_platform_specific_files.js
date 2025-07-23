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

    if (platform === 'android') {
        // Copy MainActivity.java
        var srcFile = path.join(context.opts.projectRoot, 'platform_overrides', 'android', 'MainActivity.java');
        var destFile = path.join(context.opts.projectRoot, 'platforms', 'android', 'app', 'src', 'main', 'java', 'com', 'mparticle', 'example', 'MainActivity.java');
        
        if (fs.existsSync(srcFile)) {
            try {
                ensureDirectoryExistence(destFile);
                fs.copyFileSync(srcFile, destFile);
                console.log('Copied custom MainActivity.java');
            } catch (err) {
                console.error('Error copying MainActivity.java:', err);
                process.exitCode = 1;
            }
        }
    } else if (platform === 'ios') {
        // Copy AppDelegate.m
        var srcFile = path.join(context.opts.projectRoot, 'platform_overrides', 'ios', 'AppDelegate.m');
        var destFile = path.join(context.opts.projectRoot, 'platforms', 'ios', 'MParticleExample', 'Classes', 'AppDelegate.m');
        
        if (fs.existsSync(srcFile)) {
            try {
                ensureDirectoryExistence(destFile);
                fs.copyFileSync(srcFile, destFile);
                console.log('Copied custom AppDelegate.m');
            } catch (err) {
                console.error('Error copying AppDelegate.m:', err);
                process.exitCode = 1;
            }
        }
    }
};
