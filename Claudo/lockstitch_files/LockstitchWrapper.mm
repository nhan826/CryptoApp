//
//  LockstitchWrapper.mm
//  CryptoApp Mac
//
//  Objective-C++ implementation to bridge C++ library with Swift/Objective-C

#import "LockstitchWrapper.h"
#import "Lockstitch.h"
#include <string>

@interface LockstitchWrapper ()
@property (nonatomic, copy) NSString *lastErrorMessage;
@end

@implementation LockstitchWrapper

+ (instancetype)shared {
    static LockstitchWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LockstitchWrapper alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lastErrorMessage = @"";
    }
    return self;
}

#pragma mark - String Operations

- (NSString *)encryptString:(NSString *)str {
    try {
        std::string stdStr = [str UTF8String];
        std::string result = Lockstitch::getLockstitch().encrypt(stdStr);
        return [NSString stringWithUTF8String:result.c_str()];
    } catch (const std::exception &e) {
        self.lastErrorMessage = [NSString stringWithFormat:@"Encryption error: %s", e.what()];
        return nil;
    }
}

- (NSString *)decryptString:(NSString *)str {
    try {
        std::string stdStr = [str UTF8String];
        std::string result = Lockstitch::getLockstitch().decrypt(stdStr);
        return [NSString stringWithUTF8String:result.c_str()];
    } catch (const std::exception &e) {
        self.lastErrorMessage = [NSString stringWithFormat:@"Decryption error: %s", e.what()];
        return nil;
    }
}

#pragma mark - File Operations

- (NSString *)encryptFile:(NSString *)filePath password:(NSString *)password headSize:(int)headSize {
    try {
        std::string path = [filePath UTF8String];
        std::string pw = [password UTF8String];
        std::string result = Lockstitch::getLockstitch().encryptFile(path, pw, headSize);
        return [NSString stringWithUTF8String:result.c_str()];
    } catch (const std::exception &e) {
        self.lastErrorMessage = [NSString stringWithFormat:@"File encryption error: %s", e.what()];
        return nil;
    }
}

- (NSString *)decryptFile:(NSString *)filePath password:(NSString *)password {
    try {
        std::string path = [filePath UTF8String];
        std::string pw = [password UTF8String];
        std::string result = Lockstitch::getLockstitch().decryptFile(path, pw);
        return [NSString stringWithUTF8String:result.c_str()];
    } catch (const std::exception &e) {
        self.lastErrorMessage = [NSString stringWithFormat:@"File decryption error: %s", e.what()];
        return nil;
    }
}

- (NSString *)loadTextFile:(NSString *)filePath {
    try {
        std::string path = [filePath UTF8String];
        std::string result = Lockstitch::getLockstitch().loadTxtFile(path);
        return [NSString stringWithUTF8String:result.c_str()];
    } catch (const std::exception &e) {
        self.lastErrorMessage = [NSString stringWithFormat:@"File load error: %s", e.what()];
        return nil;
    }
}

#pragma mark - Error Handling

- (NSString *)lastError {
    return self.lastErrorMessage;
}

@end
