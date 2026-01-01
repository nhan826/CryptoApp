// Mac Compatibility Fixes for Lockstitch.cpp
// Add these helper functions after the includes section

#if defined(__APPLE__) || defined(__linux__)

#include <sys/stat.h>
#include <string>
#include <locale>

// Mac/Linux compatibility for file operations
namespace {
    // Convert wide string to regular string for Mac file operations
    std::string wstring_to_string(const std::wstring& wstr) {
        if (wstr.empty()) return std::string();
        
        std::locale loc;
        std::string result;
        for (wchar_t c : wstr) {
            result += (char)c;  // Simple ASCII conversion for file paths
        }
        return result;
    }
    
    // Convert regular string to wide string
    std::wstring string_to_wstring(const std::string& str) {
        if (str.empty()) return std::wstring();
        
        std::wstring result;
        for (char c : str) {
            result += (wchar_t)(unsigned char)c;
        }
        return result;
    }
    
    // Mac/Linux equivalent of _wfopen
    FILE* mac_wfopen(const std::wstring& filename, const wchar_t* mode) {
        std::string fname = wstring_to_string(filename);
        std::string fmode;
        for (size_t i = 0; mode[i] != L'\0'; ++i) {
            fmode += (char)mode[i];
        }
        return fopen(fname.c_str(), fmode.c_str());
    }
    
    // Mac/Linux equivalent of _stat
    int mac_stat(const std::wstring& path, struct stat* buf) {
        std::string spath = wstring_to_string(path);
        return stat(spath.c_str(), buf);
    }
}

#endif

