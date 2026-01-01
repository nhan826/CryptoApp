#!/bin/bash

# CryptoApp Demo - Double-click to run!
# This script compiles and runs the demo app without any external dependencies

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEMO_FILE="$SCRIPT_DIR/CryptoApp-Demo.swift"
APP_NAME="CryptoApp-Demo"
BUILD_DIR="$SCRIPT_DIR/build_demo"

echo "🔧 Building CryptoApp Demo..."
echo "This may take 30-60 seconds on first run..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create build directory
mkdir -p "$BUILD_DIR"

# Check if demo file exists
if [ ! -f "$DEMO_FILE" ]; then
    echo "❌ Error: CryptoApp-Demo.swift not found!"
    echo "Location: $DEMO_FILE"
    read -p "Press Enter to close..."
    exit 1
fi

echo "📝 Source file: $DEMO_FILE"
echo "📦 Build directory: $BUILD_DIR"
echo ""

# Compile with swiftc (no external dependencies needed!)
echo "⏳ Compiling (this takes a moment)..."
swiftc "$DEMO_FILE" -o "$BUILD_DIR/$APP_NAME" 2>&1

if [ -f "$BUILD_DIR/$APP_NAME" ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "🚀 Launching app..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Run the compiled app
    "$BUILD_DIR/$APP_NAME"
else
    echo ""
    echo "❌ Compilation failed!"
    echo ""
    echo "💡 Make sure you have Xcode installed:"
    echo "   xcode-select --install"
    echo ""
    read -p "Press Enter to close..."
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ App closed"
read -p "Press Enter to close this window..."
