#!/bin/bash

# CryptoApp - Compile and Run
# Pre-built Lockstitch library included
# Just compiles Swift app and launches it

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build_output"
APP_BUNDLE="$SCRIPT_DIR/CryptoApp.app"
APP_EXEC="$APP_BUNDLE/Contents/MacOS/CryptoApp"

echo "🔒 CryptoApp"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check required files
if [ ! -f "$SCRIPT_DIR/liblockstitch.a" ]; then
    echo "❌ Error: Pre-built library not found!"
    echo "   Expected: $SCRIPT_DIR/liblockstitch.a"
    echo "   Make sure you extracted the artifact correctly."
    read -p "Press Enter to close..."
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/CryptoApp.swift" ]; then
    echo "❌ Error: CryptoApp.swift not found!"
    read -p "Press Enter to close..."
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/LockstitchBridge.h" ]; then
    echo "❌ Error: LockstitchBridge.h not found!"
    read -p "Press Enter to close..."
    exit 1
fi

echo "📦 Preparing to build..."
mkdir -p "$BUILD_DIR"

# Step 1: Compile Objective-C++ bridge
echo "⚙️  Compiling bridge..."
BRIDGE_OBJ="$BUILD_DIR/LockstitchBridge.o"
if ! clang++ -c "$SCRIPT_DIR/LockstitchBridge.mm" \
    -o "$BRIDGE_OBJ" \
    -fPIC \
    -fmodules \
    -std=c++11 \
    -I"$SCRIPT_DIR" 2>&1; then
    echo "❌ Bridge compilation failed!"
    echo "Run this in Terminal for full error details:"
    echo "cd $SCRIPT_DIR && clang++ -c LockstitchBridge.mm -o build_output/LockstitchBridge.o -fPIC -fmodules -std=c++11 -I."
    read -p "Press Enter to close..."
    exit 1
fi

# Step 2: Compile Swift app and link with library
echo "🔨 Compiling app..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Create Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << 'PLIST'
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
</dict>
</PLIST>

# Compile with pre-built library
echo ""
echo "Details: Compiling and linking..."
echo ""

# Also compile Lockstitch.cpp alongside the bridge
echo "Compiling Lockstitch.cpp..."
LOCKSTITCH_OBJ="$BUILD_DIR/Lockstitch.o"
clang++ -c "$SCRIPT_DIR/Lockstitch.cpp" \
    -o "$LOCKSTITCH_OBJ" \
    -fPIC \
    -std=c++11 \
    -I"$SCRIPT_DIR" 2>&1

echo "Linking Swift app..."
swiftc "$SCRIPT_DIR/CryptoApp.swift" \
    -import-objc-header "$SCRIPT_DIR/LockstitchBridge.h" \
    "$BRIDGE_OBJ" \
    "$LOCKSTITCH_OBJ" \
    -o "$APP_EXEC" \
    -framework Cocoa \
    -framework AppKit \
    -suppress-warnings

SWIFT_EXIT=$?

echo "Compilation exit code: $SWIFT_EXIT"
echo "Checking for executable at: $APP_EXEC"
ls -la "$APP_EXEC" 2>&1 || echo "Executable not found!"

if [ $SWIFT_EXIT -ne 0 ] || [ ! -f "$APP_EXEC" ]; then
    echo ""
    echo "❌ App compilation failed"
    echo ""
    echo "Debug info:"
    echo "Build directory contents:"
    ls -la "$BUILD_DIR" 2>&1 || echo "Build dir not found"
    echo ""
    echo "Source files check:"
    ls -la "$SCRIPT_DIR"/*.{swift,h,cpp} 2>&1 || echo "Missing source files"
    echo ""
    echo "Try running manually for details:"
    echo "cd $SCRIPT_DIR && swiftc CryptoApp.swift -import-objc-header LockstitchBridge.h build_output/LockstitchBridge.o build_output/Lockstitch.o -o build_output/CryptoApp -framework Cocoa -framework AppKit"
    read -p "Press Enter to close..."
    exit 1
fi

if [ ! -f "$APP_EXEC" ]; then
    echo "❌ Compilation failed"
    read -p "Press Enter to close..."
    exit 1
fi

# Make executable
chmod +x "$APP_EXEC"

echo "✅ Build complete!"
echo ""
echo "🚀 Launching..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

open "$APP_BUNDLE"

echo ""
echo "✅ CryptoApp is ready!"
echo ""
echo "📦 To share this app:"
echo "   Zip CryptoApp.app and share with others"
echo "   They can unzip and run it (no build needed)"
echo ""
read -p "Press Enter to close..."
