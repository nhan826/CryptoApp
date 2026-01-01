//
//  LockstitchWrapper.h
//  CryptoApp Mac
//
//  Objective-C++ wrapper for Lockstitch C++ library
//  This file bridges C++ code to Swift/Objective-C

#ifndef LockstitchWrapper_h
#define LockstitchWrapper_h

#import <Foundation/Foundation.h>

@interface LockstitchWrapper : NSObject

// Singleton instance
+ (instancetype)shared;

// String encryption/decryption
- (NSString * _Nullable)encryptString:(NSString *)str;
- (NSString * _Nullable)decryptString:(NSString *)str;

// File encryption/decryption
- (NSString * _Nullable)encryptFile:(NSString *)filePath password:(NSString *)password headSize:(int)headSize;
- (NSString * _Nullable)decryptFile:(NSString *)filePath password:(NSString *)password;

// File loading
- (NSString * _Nullable)loadTextFile:(NSString *)filePath;

// Error handling
- (NSString * _Nullable)lastError;

@end

#endif /* LockstitchWrapper_h */
