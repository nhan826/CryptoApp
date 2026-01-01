cmake_minimum_required(VERSION 3.10)
project(CryptoApp)

# Enable Swift support
enable_language(Swift)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_Swift_COMPILER_WORKS TRUE)

# Add platform-specific compilation flags
if(APPLE OR UNIX AND NOT APPLE)
    # Mac and Linux: Add compatibility defines
    add_compile_definitions(
        _POSIX_C_SOURCE=200809L
    )
    
    # Create a compatibility shim header
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/mac_compat.h" "
#ifndef MAC_COMPAT_H
#define MAC_COMPAT_H

#if defined(__APPLE__) || defined(__linux__)
#include <sys/stat.h>
#include <string>

// Mac/Linux file operation compatibility
inline std::string wstring_to_string(const std::wstring& wstr) {
    std::string result;
    for (wchar_t c : wstr) result += (char)c;
    return result;
}

inline FILE* mac_wfopen(const std::wstring& fname, const wchar_t* mode) {
    std::string mfname = wstring_to_string(fname);
    std::string mmode;
    for (size_t i = 0; mode[i] != L'\\0'; ++i) mmode += (char)mode[i];
    return fopen(mfname.c_str(), mmode.c_str());
}

#define _wfopen mac_wfopen
#define _stat stat
#endif

#endif // MAC_COMPAT_H
")
endif()

# Specify the source files
set(SOURCES
    Lockstitch.cpp
    pch.cpp
)

set(HEADERS
    Lockstitch.h
    pch.h
    framework.h
)

# Create static library for Mac
add_library(lockstitch STATIC ${SOURCES} ${HEADERS})

# Include directories
target_include_directories(lockstitch PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

# Platform-specific settings
if(APPLE)
    # macOS specific settings
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "Minimum macOS version")
    target_compile_definitions(lockstitch PRIVATE _MACOS)
    
    # Set architecture for universal binary (Intel + Apple Silicon)
    set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64")
endif()

# Optional: Create a shared library as well
add_library(lockstitch_shared SHARED ${SOURCES} ${HEADERS})
target_include_directories(lockstitch_shared PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

if(APPLE)
    set_target_properties(lockstitch_shared PROPERTIES
        SUFFIX ".dylib"
        PREFIX "lib"
    )
endif()

# Build Swift app executable
add_executable(CryptoApp
    ../CryptoApp.swift
)

# Link the app against the library
target_link_libraries(CryptoApp PRIVATE lockstitch)

# macOS app settings
if(APPLE)
    set_target_properties(CryptoApp PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist"
    )
    
    # Link Cocoa framework for native macOS support
    target_link_libraries(CryptoApp PRIVATE
        "-framework Cocoa"
        "-framework AppKit"
    )
endif()

# Installation
install(TARGETS lockstitch lockstitch_shared
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        RUNTIME DESTINATION bin)

install(FILES ${HEADERS} DESTINATION include/lockstitch)
