#!/bin/bash

# CryptoApp - Compile and Run
# Verbose diagnostic version

# Do NOT exit on error - we want to see all output
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build_output"
APP_BUNDLE="$SCRIPT_DIR/CryptoApp.app"
APP_EXEC="$APP_BUNDLE/Contents/MacOS/CryptoApp"

clear
echo "🔒 CryptoApp Build Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Working directory: $SCRIPT_DIR"
echo ""

# Check required files
echo "📋 Checking required files..."
echo ""

MISSING=0

if [ -f "$SCRIPT_DIR/CryptoApp.swift" ]; then
    echo "✅ CryptoApp.swift found"
else
    echo "❌ CryptoApp.swift NOT FOUND"
    MISSING=1
fi

if [ -f "$SCRIPT_DIR/LockstitchBridge.h" ]; then
    echo "✅ LockstitchBridge.h found"
else
    echo "❌ LockstitchBridge.h NOT FOUND"
    MISSING=1
fi

if [ -f "$SCRIPT_DIR/LockstitchBridge.mm" ]; then
    echo "✅ LockstitchBridge.mm found"
else
    echo "❌ LockstitchBridge.mm NOT FOUND"
    MISSING=1
fi

if [ -f "$SCRIPT_DIR/Lockstitch.h" ]; then
    echo "✅ Lockstitch.h found"
else
    echo "❌ Lockstitch.h NOT FOUND"
    MISSING=1
fi

if [ -f "$SCRIPT_DIR/Lockstitch.cpp" ]; then
    echo "✅ Lockstitch.cpp found"
else
    echo "❌ Lockstitch.cpp NOT FOUND"
    MISSING=1
fi

echo ""

if [ $MISSING -eq 1 ]; then
    echo "❌ Missing required files!"
    echo ""
    echo "Files in current directory:"
    ls -la "$SCRIPT_DIR"
    echo ""
    read -p "Press Enter to close..."
    exit 1
fi

echo "📦 All files present. Starting build..."
echo ""

mkdir -p "$BUILD_DIR"

# Step 1: Compile Objective-C++ bridge
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 1: Compiling Objective-C++ Bridge"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

BRIDGE_OBJ="$BUILD_DIR/LockstitchBridge.o"
echo "Command: clang++ -c LockstitchBridge.mm -o $BRIDGE_OBJ -fPIC -fmodules -std=c++17"
echo ""

clang++ -c "$SCRIPT_DIR/LockstitchBridge.mm" \
    -o "$BRIDGE_OBJ" \
    -fPIC \
    -fmodules \
    -std=c++17 \
    -I"$SCRIPT_DIR"

BRIDGE_EXIT=$?
echo ""
echo "Bridge compilation exit code: $BRIDGE_EXIT"

if [ ! -f "$BRIDGE_OBJ" ]; then
    echo "❌ Bridge object file not created!"
    read -p "Press Enter to close..."
    exit 1
fi

ls -lh "$BRIDGE_OBJ"
echo "✅ Bridge compiled successfully"
echo ""

# Step 2: Compile Lockstitch.cpp
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: Compiling Lockstitch.cpp"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

LOCKSTITCH_OBJ="$BUILD_DIR/Lockstitch.o"
echo "Command: clang++ -c Lockstitch.cpp -o $LOCKSTITCH_OBJ -fPIC -std=c++17"
echo ""

clang++ -c "$SCRIPT_DIR/Lockstitch.cpp" \
    -o "$LOCKSTITCH_OBJ" \
    -fPIC \
    -std=c++17 \
    -I"$SCRIPT_DIR"

LOCKSTITCH_EXIT=$?
echo ""
echo "Lockstitch compilation exit code: $LOCKSTITCH_EXIT"

if [ ! -f "$LOCKSTITCH_OBJ" ]; then
    echo "❌ Lockstitch object file not created!"
    read -p "Press Enter to close..."
    exit 1
fi

ls -lh "$LOCKSTITCH_OBJ"
echo "✅ Lockstitch compiled successfully"
echo ""

# Step 3: Create app bundle structure
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 3: Creating App Bundle"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

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

echo "✅ App bundle structure created"
echo ""

# Step 4: Compile and link Swift app
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 4: Compiling Swift App"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Command: swiftc CryptoApp.swift -import-objc-header LockstitchBridge.h ..."
echo "Linking with: $BRIDGE_OBJ and $LOCKSTITCH_OBJ"
echo ""

swiftc "$SCRIPT_DIR/CryptoApp.swift" \
    -import-objc-header "$SCRIPT_DIR/LockstitchBridge.h" \
    "$BRIDGE_OBJ" \
    "$LOCKSTITCH_OBJ" \
    -o "$APP_EXEC" \
    -framework Cocoa \
    -framework AppKit 2>&1

SWIFT_EXIT=$?
echo ""
echo "Swift compilation exit code: $SWIFT_EXIT"

if [ -f "$APP_EXEC" ]; then
    ls -lh "$APP_EXEC"
    echo "✅ Executable created successfully"
else
    echo "❌ Executable NOT created"
    echo ""
    echo "Check build directory:"
    ls -la "$BUILD_DIR"
    echo ""
    read -p "Press Enter to close..."
    exit 1
fi

echo ""

# Make executable
chmod +x "$APP_EXEC"
echo "✅ Permissions set"
echo ""

# Final check
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Build Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "App bundle: $APP_BUNDLE"
echo ""

# Count files in app
FILE_COUNT=$(find "$APP_BUNDLE" -type f | wc -l)
echo "Files in app bundle: $FILE_COUNT"

echo ""
echo "🚀 Launching CryptoApp..."
echo ""

open "$APP_BUNDLE"

sleep 1

echo ""
echo "✅ CryptoApp launched!"
echo ""
echo "If the app didn't appear, check:"
echo "1. Applications folder (may have opened there)"
echo "2. Dock (may be minimized)"
echo ""
read -p "Press Enter to close..."
