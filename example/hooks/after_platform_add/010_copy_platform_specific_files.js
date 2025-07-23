#!/usr/bin/env node

var fs = require('fs');
var path = require('path');
var shell = require('child_process');

module.exports = function(context) {
    // Get platform from context
    var platform = context.opts.platforms[0];
    
    if (platform === 'android') {
        // Copy MainActivity.java
        var srcFile = path.join(context.opts.projectRoot, 'platform_overrides', 'android', 'MainActivity.java');
        var destFile = path.join(context.opts.projectRoot, 'platforms', 'android', 'app', 'src', 'main', 'java', 'com', 'mparticle', 'example', 'MainActivity.java');
        
        if (fs.existsSync(srcFile)) {
            shell.exec(`mkdir -p "${path.dirname(destFile)}"`);
            fs.copyFileSync(srcFile, destFile);
            console.log('Copied custom MainActivity.java');
        }
    } else if (platform === 'ios') {
        // Copy AppDelegate.m
        var srcFile = path.join(context.opts.projectRoot, 'platform_overrides', 'ios', 'AppDelegate.m');
        var destFile = path.join(context.opts.projectRoot, 'platforms', 'ios', 'MParticleExample', 'Classes', 'AppDelegate.m');
        
        if (fs.existsSync(srcFile)) {
            shell.exec(`mkdir -p "${path.dirname(destFile)}"`);
            fs.copyFileSync(srcFile, destFile);
            console.log('Copied custom AppDelegate.m');
        }
    }
};
