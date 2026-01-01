#!/bin/bash

# CryptoApp - Complete build and run with SwiftUI + Lockstitch backend
# Double-click and it builds and runs everything

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build"
APP_DIR="$SCRIPT_DIR/build_app"
APP_NAME="CryptoApp"

echo "🔧 Building CryptoApp with Lockstitch backend..."
echo "This may take 1-2 minutes on first run..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check for required tools
if ! command -v cmake &> /dev/null; then
    echo "📥 Installing CMake via Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install cmake
fi

# Step 1: Build the C++ library with CMake
echo "📦 Building Lockstitch library..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if ! cmake -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DCMAKE_BUILD_TYPE=Release ..; then
    echo "❌ CMake configuration failed"
    cd "$SCRIPT_DIR"
    read -p "Press Enter to close..."
    exit 1
fi

if ! make -j4; then
    echo "❌ Library build failed"
    cd "$SCRIPT_DIR"
    read -p "Press Enter to close..."
    exit 1
fi

cd "$SCRIPT_DIR"
echo "✅ Library built"

# Step 2: Compile Swift app
echo ""
echo "🔨 Compiling Swift app..."
mkdir -p "$APP_DIR"

if [ ! -f "$SCRIPT_DIR/CryptoApp.swift" ]; then
    echo "❌ Error: CryptoApp.swift not found"
    read -p "Press Enter to close..."
    exit 1
fi

if ! swiftc "$SCRIPT_DIR/CryptoApp.swift" -o "$APP_DIR/$APP_NAME" 2>&1; then
    echo "❌ Swift compilation failed"
    read -p "Press Enter to close..."
    exit 1
fi

echo "✅ App compiled"

# Step 3: Run it!
echo ""
echo "🚀 Launching CryptoApp..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

"$APP_DIR/$APP_NAME"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -p "Press Enter to close..."
