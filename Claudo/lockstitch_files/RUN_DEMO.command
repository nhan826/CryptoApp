#!/bin/bash
set -x

# CryptoApp Build - Simple, straightforward approach
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build_output"
APP_BUNDLE="$SCRIPT_DIR/CryptoApp.app"
APP_EXEC="$APP_BUNDLE/Contents/MacOS/CryptoApp"

echo ""
echo "🔒 CryptoApp Build"
echo "Working directory: $SCRIPT_DIR"
echo ""

# Clean and prepare
rm -rf "$APP_BUNDLE" "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

echo "✅ Directories created"
echo ""

# Copy Info.plist (pre-made)
echo "Copying Info.plist..."
cp "$SCRIPT_DIR/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
if [ ! -f "$APP_BUNDLE/Contents/Info.plist" ]; then
    echo "❌ Failed to copy Info.plist"
    read -p "Press Enter to close..."
    exit 1
fi
echo "✅ Info.plist copied"
echo ""

# Step 1: Compile bridge
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 1: Compiling LockstitchBridge.mm"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
BRIDGE_OBJ="$BUILD_DIR/LockstitchBridge.o"

clang++ -c "$SCRIPT_DIR/LockstitchBridge.mm" \
    -o "$BRIDGE_OBJ" \
    -fPIC \
    -fmodules \
    -std=c++17 \
    -I"$SCRIPT_DIR"

if [ ! -f "$BRIDGE_OBJ" ]; then
    echo "❌ Bridge compilation failed"
    read -p "Press Enter to close..."
    exit 1
fi
echo "✅ Bridge compiled"
echo ""

# Step 2: Compile Lockstitch
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: Compiling Lockstitch.cpp"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
LOCKSTITCH_OBJ="$BUILD_DIR/Lockstitch.o"

clang++ -c "$SCRIPT_DIR/Lockstitch.cpp" \
    -o "$LOCKSTITCH_OBJ" \
    -fPIC \
    -std=c++17 \
    -I"$SCRIPT_DIR"

if [ ! -f "$LOCKSTITCH_OBJ" ]; then
    echo "❌ Lockstitch compilation failed"
    read -p "Press Enter to close..."
    exit 1
fi
echo "✅ Lockstitch compiled"
echo ""

# Step 3: Compile Swift
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 3: Compiling Swift App (may take 30-60 seconds)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

SWIFT_LOG="$BUILD_DIR/swift_compile.log"
echo "Starting Swift compilation..."
echo ""

# Verify input files exist
echo "Verifying input files..."
if [ ! -f "$SCRIPT_DIR/CryptoApp.swift" ]; then
    echo "❌ CryptoApp.swift not found at $SCRIPT_DIR/CryptoApp.swift"
    exit 1
fi
echo "✅ CryptoApp.swift found ($(wc -l < "$SCRIPT_DIR/CryptoApp.swift") lines)"

if [ ! -f "$SCRIPT_DIR/LockstitchBridge.h" ]; then
    echo "❌ LockstitchBridge.h not found"
    exit 1
fi
echo "✅ LockstitchBridge.h found"

if [ ! -f "$BRIDGE_OBJ" ]; then
    echo "❌ LockstitchBridge.o not found"
    exit 1
fi
echo "✅ LockstitchBridge.o found ($(stat -f%z "$BRIDGE_OBJ" 2>/dev/null || echo "?") bytes)"

if [ ! -f "$LOCKSTITCH_OBJ" ]; then
    echo "❌ Lockstitch.o not found"
    exit 1
fi
echo "✅ Lockstitch.o found ($(stat -f%z "$LOCKSTITCH_OBJ" 2>/dev/null || echo "?") bytes)"

echo ""
echo "File diagnostics:"
file "$SCRIPT_DIR/CryptoApp.swift" || true
echo ""

# Run Swift compilation, capturing all output
swiftc "$SCRIPT_DIR/CryptoApp.swift" \
    -o "$APP_EXEC" \
    -framework Cocoa \
    -framework AppKit > "$SWIFT_LOG" 2>&1

SWIFT_EXIT=$?

echo ""
echo "Swift compilation finished with exit code: $SWIFT_EXIT"
echo ""

# Show any output from the compiler
if [ -s "$SWIFT_LOG" ]; then
    echo "=== Compiler Output ==="
    cat "$SWIFT_LOG"
    echo "=== End Output ==="
    echo ""
fi

# If compilation failed, show more diagnostics
if [ $SWIFT_EXIT -ne 0 ]; then
    echo ""
    echo "=== DIAGNOSTIC INFO ==="
    echo "Swift version:"
    swift --version
    echo ""
    echo "First 20 lines of CryptoApp.swift:"
    head -20 "$SCRIPT_DIR/CryptoApp.swift"
    echo ""
    echo "Last 20 lines of CryptoApp.swift:"
    tail -20 "$SCRIPT_DIR/CryptoApp.swift"
    echo ""
    echo "File encoding:"
    file -I "$SCRIPT_DIR/CryptoApp.swift"
    echo "=== END DIAGNOSTIC ==="
    echo ""
fi

if [ $SWIFT_EXIT -ne 0 ]; then
    echo "❌ Swift compilation FAILED (exit code: $SWIFT_EXIT)"
    echo ""
    echo "Build directory:"
    ls -la "$BUILD_DIR"
    echo ""
    read -p "Press Enter to close..."
    exit 1
fi

if [ ! -f "$APP_EXEC" ]; then
    echo "❌ Executable was not created even though exit code was 0"
    echo ""
    echo "Build directory:"
    ls -la "$BUILD_DIR"
    echo ""
    read -p "Press Enter to close..."
    exit 1
fi

echo "✅ Swift app compiled"
echo ""

# Make executable
chmod +x "$APP_EXEC"
echo "✅ Permissions set"
echo ""

# Launch
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ BUILD COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Launching CryptoApp..."
echo ""

open "$APP_BUNDLE"

sleep 2
echo "✅ CryptoApp launched!"
echo ""
read -p "Press Enter to close..."
