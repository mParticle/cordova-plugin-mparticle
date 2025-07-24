#!/usr/bin/env node

var shell = require('child_process');
var path = require('path');

module.exports = function(context) {
    // Skip if not iOS
    if (context.opts.platforms.indexOf('ios') === -1) {
        return;
    }

    console.log('Running pod install for iOS platform...');

    // Get the path to the iOS platform directory
    var iosPath = path.join(context.opts.projectRoot, 'platforms', 'ios');
    
    return new Promise((resolve, reject) => {
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
