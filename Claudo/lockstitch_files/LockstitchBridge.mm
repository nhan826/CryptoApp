#import "LockstitchBridge.h"
#include "Lockstitch.h"
#include <string>
#include <sstream>
#include <fstream>

// Helper: Convert NSString to std::string
static std::string nsStringToString(NSString *str) {
    return std::string([str UTF8String]);
}

// Helper: Convert std::string to NSString
static NSString *stringToNSString(const std::string &str) {
    return [NSString stringWithUTF8String:str.c_str()];
}

// Helper: Convert std::string to hex NSString for output
static NSString *bytesToHexString(const std::string &bytes) {
    NSMutableString *hex = [NSMutableString string];
    for (unsigned char c : bytes) {
        [hex appendFormat:@"%02x", c];
    }
    return hex;
}

// Helper: Convert hex NSString back to std::string
static std::string hexStringToBytes(NSString *hexStr) {
    std::string result;
    NSString *str = hexStr;
    for (NSUInteger i = 0; i < str.length; i += 2) {
        NSString *hex = [str substringWithRange:NSMakeRange(i, 2)];
        unsigned int byte;
        sscanf([hex UTF8String], "%x", &byte);
        result.push_back((unsigned char)byte);
    }
    return result;
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

+ (BOOL)encryptFile:(NSString *)inputPath outputPath:(NSString *)outputPath {
    try {
        // Convert NSString paths to std::string
        std::string inPath = nsStringToString(inputPath);
        std::string outPath = nsStringToString(outputPath);
        
        // Call Lockstitch file encryption
        Lockstitch& lockstitch = Lockstitch::getLockstitch();
        std::string result = lockstitch.encryptFile(inPath);
        
        // Write result to output file
        std::ofstream outFile(outPath, std::ios::binary);
        if (!outFile.is_open()) {
            return NO;
        }
        outFile.write(result.c_str(), result.length());
        outFile.close();
        
        return YES;
    } catch (const std::exception &e) {
        return NO;
    }
}

+ (BOOL)decryptFile:(NSString *)inputPath outputPath:(NSString *)outputPath {
    try {
        // Convert NSString paths to std::string
        std::string inPath = nsStringToString(inputPath);
        std::string outPath = nsStringToString(outputPath);
        
        // Call Lockstitch file decryption
        Lockstitch& lockstitch = Lockstitch::getLockstitch();
        std::string result = lockstitch.decryptFile(inPath);
        
        // Write result to output file
        std::ofstream outFile(outPath, std::ios::binary);
        if (!outFile.is_open()) {
            return NO;
        }
        outFile.write(result.c_str(), result.length());
        outFile.close();
        
        return YES;
    } catch (const std::exception &e) {
        return NO;
    }
}

@end
