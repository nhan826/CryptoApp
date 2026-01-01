#!/bin/bash

# CryptoApp - Full version with Lockstitch library
# This script builds the library and launches the native macOS app

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build"
LIBRARY_FILE="$BUILD_DIR/liblockstitch.a"

echo "🔧 Building CryptoApp with Lockstitch Library..."
echo "This may take 1-2 minutes on first run..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Build the Lockstitch library if needed
if [ ! -f "$LIBRARY_FILE" ]; then
    echo "📦 Building Lockstitch library..."
    
    if ! command -v cmake &> /dev/null; then
        echo "📥 Installing CMake via Homebrew..."
        if ! command -v brew &> /dev/null; then
            echo "Installing Homebrew first..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install cmake
    fi
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    cmake -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DCMAKE_BUILD_TYPE=Release .. 2>&1
    make -j4 2>&1
    cd "$SCRIPT_DIR"
    
    if [ ! -f "$LIBRARY_FILE" ]; then
        echo "❌ Failed to build library"
        read -p "Press Enter to close..."
        exit 1
    fi
    echo "✅ Library built successfully"
else
    echo "✅ Library already built"
fi

echo ""
echo "🚀 Opening Xcode project..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "The CryptoApp.xcodeproj is ready to open in Xcode."
echo "To build and run:"
echo "  1. Open CryptoApp.xcodeproj in Xcode"
echo "  2. Select 'CryptoApp' as the target"
echo "  3. Press Cmd+R to build and run"
echo ""

# Look for Xcode project
XCODE_PROJECT="../CryptoApp.xcodeproj"
if [ -d "$XCODE_PROJECT" ]; then
    open "$XCODE_PROJECT"
else
    echo "⚠️  Xcode project not found at: $XCODE_PROJECT"
    echo "Checked location: $(cd .. && pwd)/CryptoApp.xcodeproj"
fi

echo ""
read -p "Press Enter to close this window..."
