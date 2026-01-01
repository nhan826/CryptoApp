#!/bin/bash

# CryptoApp - Production Build
# Builds Lockstitch library + Swift app with real encryption backend
# Creates a standalone .app bundle ready to share

set -e  # Exit on any error

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build_production"
APP_BUNDLE="$SCRIPT_DIR/CryptoApp.app"
APP_CONTENTS="$APP_BUNDLE/Contents/MacOS"

echo "🔒 CryptoApp - Production Build"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Check dependencies
echo "📋 Checking dependencies..."
if ! command -v cmake &> /dev/null; then
    echo "📥 Installing CMake..."
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install cmake > /dev/null 2>&1
fi
echo "✅ Dependencies ready"

# Step 2: Build Lockstitch library with CMake
echo ""
echo "📦 Building Lockstitch library..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "  Running CMake..."
cmake -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DCMAKE_BUILD_TYPE=Release ..
if [ $? -ne 0 ]; then
    echo "❌ CMake failed"
    cd "$SCRIPT_DIR"
    read -p "Press Enter to close..."
    exit 1
fi

echo "  Compiling with make..."
make -j4
if [ $? -ne 0 ]; then
    echo "❌ Make failed"
    cd "$SCRIPT_DIR"
    read -p "Press Enter to close..."
    exit 1
fi

LIBRARY_FILE="$BUILD_DIR/liblockstitch.a"
if [ ! -f "$LIBRARY_FILE" ]; then
    echo "❌ Library file not created at: $LIBRARY_FILE"
    ls -la "$BUILD_DIR/" | head -20
    cd "$SCRIPT_DIR"
    read -p "Press Enter to close..."
    exit 1
fi
echo "✅ Library built: $LIBRARY_FILE"

cd "$SCRIPT_DIR"

# Step 3: Prepare app bundle
echo ""
echo "🏗️  Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_CONTENTS"

# Create Info.plist
mkdir -p "$APP_BUNDLE/Contents/Resources"
cat > "$APP_BUNDLE/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>CryptoApp</string>
    <key>CFBundleIdentifier</key>
    <string>com.cryptoapp.mac</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>CryptoApp</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# Step 4: Compile Swift app with Objective-C++ bridge
echo ""
echo "🔨 Compiling Swift app with Lockstitch bridge..."

# Compile Objective-C++ wrapper
echo "  Compiling Objective-C++ bridge..."
WRAPPER_OBJ="$BUILD_DIR/LockstitchBridge.o"
clang++ -c "$SCRIPT_DIR/LockstitchBridge.mm" \
    -o "$WRAPPER_OBJ" \
    -fPIC \
    -fmodules \
    -I"$SCRIPT_DIR" \
    -I"$BUILD_DIR" 2>&1 | head -20

if [ ! -f "$WRAPPER_OBJ" ]; then
    echo "⚠️  Objective-C++ compilation had issues, continuing..."
fi

# Compile Swift app and link everything
echo "  Compiling Swift app..."
swiftc "$SCRIPT_DIR/CryptoApp.swift" \
    -import-objc-header "$SCRIPT_DIR/LockstitchBridge.h" \
    "$WRAPPER_OBJ" \
    "$LIBRARY_FILE" \
    -o "$APP_CONTENTS/CryptoApp" \
    -framework Cocoa \
    -framework AppKit 2>&1

if [ ! -f "$APP_CONTENTS/CryptoApp" ]; then
    echo "❌ Failed to compile Swift app"
    read -p "Press Enter to close..."
    exit 1
fi

echo "✅ App compiled and linked"

# Step 5: Launch
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Launching CryptoApp..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

open "$APP_BUNDLE"

echo ""
echo "✅ Done! App bundle created at:"
echo "   $APP_BUNDLE"
echo ""
echo "To share this app with others:"
echo "   1. Zip the CryptoApp.app folder"
echo "   2. Share the zip file"
echo "   3. They can unzip and run it directly (no build needed)"
echo ""
read -p "Press Enter to close..."
