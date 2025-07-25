#!/usr/bin/env node

var fs = require('fs');
var path = require('path');

module.exports = function(context) {
    // Skip if not Android
    if (context.opts.platforms.indexOf('android') === -1) {
        return;
    }

    console.log('Copying Android build-extras.gradle...');

    // Source and destination paths
    var srcFile = path.join(context.opts.projectRoot, 'platform_overrides', 'android', 'build-extras.gradle');
    var destFile = path.join(context.opts.projectRoot, 'platforms', 'android', 'app', 'build-extras.gradle');

    try {
        // Ensure the source file exists
        if (!fs.existsSync(srcFile)) {
            console.error('build-extras.gradle not found in platform_overrides');
            return;
        }

        // Copy the file
        fs.copyFileSync(srcFile, destFile);
        console.log('Successfully copied build-extras.gradle to platform directory');
    } catch (error) {
        console.error('Error copying build-extras.gradle:', error);
        throw error;
    }
};
