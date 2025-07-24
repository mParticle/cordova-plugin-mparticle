#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Directories to clean
const DIRS_TO_REMOVE = [
    'platforms',
    'plugins',
    'node_modules'
];

// Files to clean
const FILES_TO_REMOVE = [
    'package-lock.json'
];

function clean() {
    const projectRoot = path.join(__dirname, '..');
    console.log('🧹 Cleaning project...');

    // Remove directories
    DIRS_TO_REMOVE.forEach(dir => {
        const dirPath = path.join(projectRoot, dir);
        if (fs.existsSync(dirPath)) {
            console.log(`📁 Removing ${dir}...`);
            fs.rmSync(dirPath, { recursive: true, force: true });
        }
    });

    // Remove files
    FILES_TO_REMOVE.forEach(file => {
        const filePath = path.join(projectRoot, file);
        if (fs.existsSync(filePath)) {
            console.log(`📄 Removing ${file}...`);
            fs.unlinkSync(filePath);
        }
    });

    // Run npm install to get a fresh node_modules
    console.log('📦 Installing fresh dependencies...');
    execSync('npm install', { 
        cwd: projectRoot,
        stdio: 'inherit'
    });

    console.log('✨ Clean completed successfully!');
}

clean();
