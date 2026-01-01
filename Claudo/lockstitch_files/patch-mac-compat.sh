#!/bin/bash
# Mac compatibility patcher for Lockstitch.cpp
# This script adds Mac compatibility without modifying original logic

LOCKSTITCH_CPP="Lockstitch.cpp"
BACKUP_FILE="${LOCKSTITCH_CPP}.bak"

# Check if file exists
if [ ! -f "$LOCKSTITCH_CPP" ]; then
    echo "Error: $LOCKSTITCH_CPP not found"
    exit 1
fi

# Create backup (only if not already backed up)
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$LOCKSTITCH_CPP" "$BACKUP_FILE"
    echo "Backup created: $BACKUP_FILE"
fi

# Add Mac compatibility includes after the standard includes
# This adds the compatibility layer without modifying encryption logic

sed -i.tmp '/#include <stdio.h>/a\
\
#if defined(__APPLE__) || defined(__linux__)\
#include <sys/stat.h>\
/* Mac/Linux compatibility helpers */\
inline std::string wstring_to_string(const std::wstring& wstr) {\
    std::string result; for (wchar_t c : wstr) result += (char)c; return result;\
}\
inline FILE* mac_wfopen(const std::wstring& fname, const wchar_t* mode) {\
    std::string mfname = wstring_to_string(fname);\
    std::string mmode; for (size_t i = 0; mode[i] != L'\'\'0'\'\''; ++i) mmode += (char)mode[i];\
    return fopen(mfname.c_str(), mmode.c_str());\
}\
#define _wfopen mac_wfopen\
#define _stat stat\
#define _stat64 stat\
#endif\
' "$LOCKSTITCH_CPP"

# Clean up sed temp file
rm -f "${LOCKSTITCH_CPP}.tmp"

echo "Mac compatibility patches applied to $LOCKSTITCH_CPP"
