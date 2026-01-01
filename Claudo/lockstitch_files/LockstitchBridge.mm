#import "LockstitchBridge.h"
#include "Lockstitch.h"
#include <string>
#include <sstream>

// Helper: Convert NSString to std::string
static std::string nsStringToString(NSString *str) {
    return std::string([str UTF8String]);
}

// Helper: Convert std::string to NSString
static NSString *stringToNSString(const std::string &str) {
    return [NSString stringWithUTF8String:str.c_str()];
}

@implementation LockstitchBridge

+ (NSString *)encryptString:(NSString *)plaintext {
    try {
        // Convert NSString to std::string
        std::string input = nsStringToString(plaintext);
        
        // Call actual Lockstitch encryption
        Lockstitch& lockstitch = Lockstitch::getLockstitch();
        std::string output = lockstitch.encrypt(input);
        
        // Output is already in hex format from Lockstitch
        return stringToNSString(output);
    } catch (const std::exception &e) {
        return [NSString stringWithFormat:@"Error: %s", e.what()];
    }
}

+ (NSString *)decryptString:(NSString *)ciphertext {
    try {
        // Convert NSString to std::string (already in hex from encrypt)
        std::string input = nsStringToString(ciphertext);
        
        // Call actual Lockstitch decryption
        Lockstitch& lockstitch = Lockstitch::getLockstitch();
        std::string output = lockstitch.decrypt(input);
        
        return stringToNSString(output);
    } catch (const std::exception &e) {
        return [NSString stringWithFormat:@"Error: %s", e.what()];
    }
}

@end
