#!/bin/bash

# CryptoApp - Just compile and run. That's it.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_DIR="$SCRIPT_DIR/CryptoApp.app/Contents/MacOS"
APP_NAME="CryptoApp"

echo "🔧 Building CryptoApp..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Compile the Swift app
mkdir -p "$APP_DIR"

echo "Compiling app..."
if swiftc "$SCRIPT_DIR/CryptoApp.swift" -o "$APP_DIR/$APP_NAME" 2>&1; then
    echo "✅ Built successfully!"
    echo ""
    echo "🚀 Launching..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Run the app
    open -a "$APP_DIR/.." --args
else
    echo "❌ Build failed"
    echo "Make sure you have Xcode Command Line Tools installed:"
    echo "  xcode-select --install"
    read -p "Press Enter to close..."
    exit 1
fi

echo ""
read -p "Press Enter to close..."
