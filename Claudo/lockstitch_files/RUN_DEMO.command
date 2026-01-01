#!/bin/bash

# CryptoApp - Complete build and run with SwiftUI + Lockstitch backend
# Double-click and it builds and runs everything

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build"
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

# Build everything with CMake
echo "📦 Building library and app..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure
cmake -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DCMAKE_BUILD_TYPE=Release .. 2>&1 | grep -E "(error|warning|Built target)" || true

# Build
if ! make -j4 2>&1; then
    echo ""
    echo "❌ Build failed"
    cd "$SCRIPT_DIR"
    read -p "Press Enter to close..."
    exit 1
fi

cd "$SCRIPT_DIR"

# Check if app was built
if [ ! -f "$BUILD_DIR/$APP_NAME" ]; then
    echo "❌ App executable not found"
    read -p "Press Enter to close..."
    exit 1
fi

echo ""
echo "✅ Build successful!"
echo ""
echo "🚀 Launching CryptoApp..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Run the app
"$BUILD_DIR/$APP_NAME"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -p "Press Enter to close..."
