#!/usr/bin/env node

var shell = require('child_process');
var path = require('path');
var fs = require('fs');

module.exports = function(context) {
    // Skip if not iOS
    if (context.opts.platforms.indexOf('ios') === -1) {
        return;
    }

    console.log('Setting up iOS pods...');

    // Get the paths
    var iosPath = path.join(context.opts.projectRoot, 'platforms', 'ios');
    var customPodfilePath = path.join(context.opts.projectRoot, 'platform_overrides', 'ios', 'Podfile');
    var platformPodfilePath = path.join(iosPath, 'Podfile');
    
    return new Promise((resolve, reject) => {
        // Copy custom Podfile if it exists
        if (fs.existsSync(customPodfilePath)) {
            try {
                fs.copyFileSync(customPodfilePath, platformPodfilePath);
                console.log('Copied custom Podfile');
            } catch (error) {
                console.error('Error copying Podfile: ' + error);
                reject(error);
                return;
            }
        }

        // Run pod install
        shell.exec('pod install', { cwd: iosPath }, function(error, stdout, stderr) {
            if (error) {
                console.error('Error running pod install: ' + error);
                console.error('stderr: ' + stderr);
                reject(error);
                return;
            }
            console.log('pod install output: ' + stdout);
            resolve();
        });
    });
};
