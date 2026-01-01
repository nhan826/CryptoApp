#import <Foundation/Foundation.h>

// Swift-compatible Objective-C interface to Lockstitch encryption
@interface LockstitchBridge : NSObject

+ (NSString *)encryptString:(NSString *)plaintext;
+ (NSString *)decryptString:(NSString *)ciphertext;

@end
