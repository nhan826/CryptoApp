#!/bin/bash
# Build script for CryptoApp macOS
# This script builds a complete .app bundle

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building CryptoApp for macOS...${NC}"

# Directories
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
APP_NAME="CryptoApp"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo -e "${YELLOW}Step 1: Creating app bundle structure...${NC}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

echo -e "${YELLOW}Step 2: Copying files...${NC}"
# Copy Info.plist
cp Info.plist "${CONTENTS_DIR}/Info.plist"

# Copy library
cp Lockstitch/liblockstitch.a "${MACOS_DIR}/"

echo -e "${YELLOW}Step 3: Compiling Swift files...${NC}"
# Compile Swift files
swiftc -o "${MACOS_DIR}/${APP_NAME}" \
    -F "${MACOS_DIR}" \
    -framework Cocoa \
    -isysroot "$(xcrun --show-sdk-path)" \
    -target "$(uname -m)-apple-macosx10.13" \
    AppDelegate.swift \
    ViewController.swift \
    Lockstitch/LockstitchWrapper.mm \
    Lockstitch/Lockstitch.cpp \
    Lockstitch/pch.cpp \
    -lc++ \
    "${MACOS_DIR}/liblockstitch.a"

echo -e "${YELLOW}Step 4: Setting executable permissions...${NC}"
chmod +x "${MACOS_DIR}/${APP_NAME}"

echo -e "${GREEN}✅ Build complete!${NC}"
echo -e "${GREEN}App created at: ${APP_DIR}${NC}"
echo -e "${GREEN}To run: open \"${APP_DIR}\"${NC}"
