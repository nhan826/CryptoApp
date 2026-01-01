cmake_minimum_required(VERSION 3.10)
project(Lockstitch)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

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
target_include_directories(lockstitch PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

# Platform-specific settings
if(APPLE)
    # macOS specific settings
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "Minimum macOS version")
    target_compile_definitions(lockstitch PRIVATE _MACOS)
    
    # Optional: Set architecture for universal binary (Intel + Apple Silicon)
    set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64")
endif()

# Optional: Create a shared library as well
add_library(lockstitch_shared SHARED ${SOURCES} ${HEADERS})
target_include_directories(lockstitch_shared PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

if(APPLE)
    set_target_properties(lockstitch_shared PROPERTIES
        SUFFIX ".dylib"
        PREFIX "lib"
    )
endif()

# Installation
install(TARGETS lockstitch lockstitch_shared
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        RUNTIME DESTINATION bin)

install(FILES ${HEADERS} DESTINATION include/lockstitch)
