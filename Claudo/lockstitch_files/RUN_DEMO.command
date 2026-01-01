#!/bin/bash

# CryptoApp - Complete build and run (no Xcode needed!)
# Double-click and it just works

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOCKSTITCH_DIR="$SCRIPT_DIR/Lockstitch"
BUILD_DIR="$LOCKSTITCH_DIR/build"
LIBRARY_FILE="$BUILD_DIR/liblockstitch.a"
APP_DIR="$SCRIPT_DIR/build_app"
APP_NAME="CryptoApp"

echo "🔧 Building CryptoApp..."
echo "This may take 1-2 minutes on first run..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Lockstitch directory exists
if [ ! -d "$LOCKSTITCH_DIR" ]; then
    echo "❌ Error: Lockstitch directory not found"
    read -p "Press Enter to close..."
    exit 1
fi

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
    echo "✅ Library built"
else
    echo "✅ Library ready"
fi

# Step 2: Compile Swift app
echo ""
echo "🔨 Compiling Swift app..."
mkdir -p "$APP_DIR"

DEMO_FILE="$SCRIPT_DIR/CryptoApp-Demo.swift"
if [ ! -f "$DEMO_FILE" ]; then
    echo "❌ Error: CryptoApp-Demo.swift not found"
    read -p "Press Enter to close..."
    exit 1
fi

swiftc "$DEMO_FILE" -o "$APP_DIR/$APP_NAME" 2>&1

if [ ! -f "$APP_DIR/$APP_NAME" ]; then
    echo "❌ Failed to compile app"
    read -p "Press Enter to close..."
    exit 1
fi

echo "✅ App compiled"

# Step 3: Run it!
echo ""
echo "🚀 Launching..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

"$APP_DIR/$APP_NAME"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -p "Press Enter to close..."
