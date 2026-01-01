# Mac Build Instructions for Lockstitch Library

## Overview
This document provides step-by-step instructions to:
1. Compile the Lockstitch C++ library for macOS
2. Create a macOS user interface using Swift/Xcode
3. Integrate the library with the UI

## Prerequisites
- macOS 10.13 or later
- Xcode 11.0 or later (with Command Line Tools)
- CMake 3.10 or later
- Git (optional, for version control)

## Step 1: Install CMake (if not already installed)

### Using Homebrew (recommended):
```bash
brew install cmake
```

### Using MacPorts:
```bash
sudo port install cmake
```

### Verify installation:
```bash
cmake --version
```

## Step 2: Compile the Lockstitch Library

### Navigate to the library directory:
```bash
cd /path/to/lockstitch_files
```

### Create a build directory:
```bash
mkdir build
cd build
```

### Generate build files with CMake:
```bash
cmake ..
```

### Build the library:
```bash
make
```

### (Optional) Build universal binary for both Intel and Apple Silicon:
```bash
cmake -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" ..
make
```

### Output files:
- **Static library**: `build/liblockstitch.a` (recommended for distribution)
- **Shared library**: `build/liblockstitch.dylib` (if enabled)

## Step 3: Create Xcode Project

### Option A: Create a new macOS App project in Xcode

1. Open Xcode
2. File → New → Project
3. Select **macOS** → **App**
4. Configure:
   - Product Name: `CryptoApp`
   - Team ID: (your team)
   - Language: **Swift**
   - Click **Create**

### Option B: Generate Xcode project from CMake (Advanced)
```bash
cd build
cmake -G Xcode ..
open Lockstitch.xcodeproj
```

## Step 4: Add Lockstitch Library to Xcode Project

1. **Copy header files** to your project:
   - Copy `Lockstitch.h`, `pch.h`, `framework.h` to your Xcode project
   - In Xcode: File → Add Files to Project → select the header files

2. **Copy the compiled library** to your project:
   - Copy `build/liblockstitch.a` to your Xcode project folder

3. **Link the library in Build Settings**:
   - Select the project in Xcode
   - Select your target
   - Go to **Build Phases** → **Link Binary With Libraries**
   - Click **+** and add `liblockstitch.a`

4. **Configure Header Search Paths**:
   - Select the project → Select target
   - Go to **Build Settings**
   - Search for "Header Search Paths"
   - Add the path to your lockstitch_files directory

## Step 5: Add Objective-C++ Wrapper

1. **Create a bridging header** (if not using Objective-C++):
   - Create a file named `CryptoApp-Bridging-Header.h`
   - Add the following content:
   ```objc
   //
   //  CryptoApp-Bridging-Header.h
   //

   #ifndef CryptoApp_Bridging_Header_h
   #define CryptoApp_Bridging_Header_h

   #import "LockstitchWrapper.h"

   #endif /* CryptoApp_Bridging_Header_h */
   ```

2. **Configure Bridging Header in Build Settings**:
   - Select the project → Select target
   - Go to **Build Settings**
   - Search for "Bridging Header"
   - Set the value to `CryptoApp/CryptoApp-Bridging-Header.h` (adjust path as needed)

3. **Add Wrapper Files to Project**:
   - Copy `LockstitchWrapper.h` and `LockstitchWrapper.mm` to your Xcode project
   - Add them to your target in Build Phases

## Step 6: Configure Code File Location

The library requires a `Code.txt` file at runtime. You have two options:

### Option 1: Place Code.txt in the app bundle
```bash
# In your Xcode project, add Code.txt to:
# Your app target → Build Phases → Copy Bundle Resources
# Place Code.txt in the same directory as the compiled library
```

### Option 2: Use a default constant string
The library has a built-in fallback constant string if `Code.txt` is not found.

## Step 7: Implement the UI (ViewController.swift)

1. The provided `ViewController.swift` file contains a complete example UI with:
   - Text encryption/decryption
   - File encryption/decryption
   - Password protection
   - Error handling and status messages

2. Customize the UI in Xcode's Interface Builder:
   - Create UI elements matching the @IBOutlet declarations
   - Connect them to the ViewController

## Step 8: Build and Run

### Build the project:
```bash
Cmd + B
```

### Run the project:
```bash
Cmd + R
```

## API Reference

### Available Methods in LockstitchWrapper

#### String Operations
```swift
// Encrypt a string
let encrypted = LockstitchWrapper.shared().encryptString(plaintext)

// Decrypt a string
let decrypted = LockstitchWrapper.shared().decryptString(encrypted)
```

#### File Operations
```swift
// Encrypt a file
let result = LockstitchWrapper.shared().encryptFile(
    filePath: "/path/to/file",
    password: "yourPassword",
    headSize: 0
)

// Decrypt a file
let result = LockstitchWrapper.shared().decryptFile(
    filePath: "/path/to/file",
    password: "yourPassword"
)

// Load text file
let content = LockstitchWrapper.shared().loadTextFile(filePath: "/path/to/file")
```

#### Error Handling
```swift
// Get the last error message
let error = LockstitchWrapper.shared().lastError()
```

## Troubleshooting

### CMake not found
- Install CMake using Homebrew: `brew install cmake`
- Add to PATH if needed: `export PATH="/usr/local/bin:$PATH"`

### Linker errors (undefined reference to Lockstitch::)
- Verify `liblockstitch.a` is added in **Build Phases → Link Binary With Libraries**
- Check Header Search Paths include the correct directory
- Ensure the library was built successfully (check build/liblockstitch.a exists)

### Bridging header not found
- Verify the path in Build Settings matches your project structure
- Make sure the file exists at that location

### "Code.txt not found" at runtime
- Place Code.txt in the app bundle (Build Phases → Copy Bundle Resources)
- Or the library will use the built-in constant string

### Architecture mismatch errors
- Verify your Xcode build architecture matches the library
- Use universal binary: `cmake -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"`

## Key Design Points

1. **No Source Code Modification**: The original Lockstitch.cpp and Lockstitch.h remain unchanged
2. **Consistency**: Use the same library across Windows, Mac, and Mobile platforms
3. **Platform-Specific UI**: Create native UI for each platform while using the same underlying library
4. **Objective-C++ Bridge**: LockstitchWrapper handles C++ to Swift/Objective-C conversion

## Directory Structure (Recommended)

```
CryptoApp-Mac/
├── CryptoApp/
│   ├── AppDelegate.swift
│   ├── ViewController.swift
│   ├── Main.storyboard
│   ├── CryptoApp-Bridging-Header.h
│   └── Assets.xcassets/
├── Lockstitch/
│   ├── Lockstitch.cpp
│   ├── Lockstitch.h
│   ├── pch.h
│   ├── pch.cpp
│   ├── framework.h
│   ├── LockstitchWrapper.h
│   ├── LockstitchWrapper.mm
│   ├── CMakeLists.txt
│   ├── build/
│   │   └── liblockstitch.a
│   └── Code.txt
└── CryptoApp.xcodeproj/
```

## Additional Resources

- CMake Documentation: https://cmake.org/documentation/
- Xcode Documentation: https://developer.apple.com/xcode/
- Objective-C++ Guide: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjectiveC/
- Swift and Objective-C Interoperability: https://developer.apple.com/documentation/swift/importing_objective_c_into_swift

## Support

For issues with the Lockstitch library itself, refer to the original Windows implementation in `Claudo.exe` for reference behavior.
