#!/bin/bash

# CryptoApp Demo - Double-click to run!
# This script compiles and runs the demo app without any external dependencies

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEMO_FILE="$SCRIPT_DIR/CryptoApp-Demo.swift"
APP_NAME="CryptoApp-Demo"
BUILD_DIR="$SCRIPT_DIR/build_demo"

echo "🔧 Building CryptoApp Demo..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create build directory
mkdir -p "$BUILD_DIR"

# Compile with swiftc (no external dependencies needed!)
if swiftc "$DEMO_FILE" -o "$BUILD_DIR/$APP_NAME" 2>/dev/null; then
    echo "✅ Build successful!"
    echo ""
    echo "🚀 Launching app..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Run the compiled app
    "$BUILD_DIR/$APP_NAME"
else
    echo ""
    echo "❌ Build failed. Trying alternative method..."
    echo ""
    
    # Try with SDK explicitly set
    MACOS_SDK=$(xcrun --show-sdk-path --sdk macosx 2>/dev/null)
    if [ ! -z "$MACOS_SDK" ]; then
        swiftc "$DEMO_FILE" -o "$BUILD_DIR/$APP_NAME" -isysroot "$MACOS_SDK" -F "$MACOS_SDK/System/Library/Frameworks"
        "$BUILD_DIR/$APP_NAME"
    else
        echo "❌ Error: Swift compiler not found or macOS SDK unavailable"
        echo "💡 Try running: xcode-select --install"
        read -p "Press Enter to close..."
        exit 1
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ App closed"
read -p "Press Enter to close this window..."
