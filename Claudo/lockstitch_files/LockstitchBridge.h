#import <Foundation/Foundation.h>

// Swift-compatible Objective-C interface to Lockstitch encryption
@interface LockstitchBridge : NSObject

+ (NSString *)encryptString:(NSString *)plaintext;
+ (NSString *)decryptString:(NSString *)ciphertext;
+ (BOOL)encryptFile:(NSString *)inputPath outputPath:(NSString *)outputPath;
+ (BOOL)decryptFile:(NSString *)inputPath outputPath:(NSString *)outputPath;

@end
