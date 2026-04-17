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
        var destFile = path.join(context.opts.projectRoot, 'platforms', 'ios', 'MParticleExample', 'AppDelegate.m');

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

        // Copy RoktPaymentSetup.swift for shoppable ads example
        var swiftSrc = path.join(context.opts.projectRoot, 'platform_overrides', 'ios', 'RoktPaymentSetup.swift');
        var swiftDest = path.join(context.opts.projectRoot, 'platforms', 'ios', 'MParticleExample', 'RoktPaymentSetup.swift');
        if (fs.existsSync(swiftSrc)) {
            try {
                fs.copyFileSync(swiftSrc, swiftDest);
                console.log('Copied RoktPaymentSetup.swift');
            } catch (err) {
                console.error('Error copying RoktPaymentSetup.swift:', err);
            }
        }

        // Create bridging header for Swift/ObjC interop
        var bridgingHeaderPath = path.join(context.opts.projectRoot, 'platforms', 'ios', 'MParticleExample', 'MParticleExample-Bridging-Header.h');
        if (!fs.existsSync(bridgingHeaderPath)) {
            try {
                fs.writeFileSync(bridgingHeaderPath, '// Bridging header for Swift/ObjC interop\n');
                console.log('Created bridging header');
            } catch (err) {
                console.error('Error creating bridging header:', err);
            }
        }

        // Add RoktStripePaymentExtension pod for shoppable ads example
        var podfilePath = path.join(context.opts.projectRoot, 'platforms', 'ios', 'Podfile');
        if (fs.existsSync(podfilePath)) {
            try {
                var podfileContent = fs.readFileSync(podfilePath, 'utf8');
                if (!podfileContent.includes('RoktStripePaymentExtension')) {
                    podfileContent = podfileContent.replace(
                        /end\s*$/m,
                        "  pod 'RoktStripePaymentExtension', '~> 0.1'\nend"
                    );
                    fs.writeFileSync(podfilePath, podfileContent);
                    console.log('Added RoktStripePaymentExtension pod to Podfile');
                    shell.execSync('cd ' + path.join(context.opts.projectRoot, 'platforms', 'ios') + ' && pod install', { stdio: 'inherit' });
                }
            } catch (err) {
                console.error('Error adding RoktStripePaymentExtension pod:', err);
            }
        }

        // Add Swift file to Xcode project and configure Swift settings
        var iosPath = path.join(context.opts.projectRoot, 'platforms', 'ios');
        try {
            shell.execSync('cd ' + iosPath + ' && ruby -e \'' +
                'require "xcodeproj"\n' +
                'proj = Xcodeproj::Project.open("MParticleExample.xcodeproj")\n' +
                'target = proj.targets.find { |t| t.name == "MParticleExample" }\n' +
                'group = proj.main_group.find_subpath("MParticleExample", false)\n' +
                'swift_ref = group.new_file("RoktPaymentSetup.swift")\n' +
                'target.source_build_phase.add_file_reference(swift_ref)\n' +
                'target.build_configurations.each do |config|\n' +
                '  config.build_settings["SWIFT_VERSION"] = "5.0"\n' +
                '  config.build_settings["SWIFT_OBJC_BRIDGING_HEADER"] = "MParticleExample/MParticleExample-Bridging-Header.h"\n' +
                'end\n' +
                'proj.save\n' +
                'puts "Configured Xcode project for Swift/Shoppable Ads"\n' +
            '\'', { stdio: 'inherit' });
        } catch (err) {
            console.error('Error configuring Xcode project:', err);
        }
    }
};
