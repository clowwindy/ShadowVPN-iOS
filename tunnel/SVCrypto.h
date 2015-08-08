//
//  SVCrypto.h
//  ShadowVPN
//
//  Created by clowwindy on 7/18/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVCrypto : NSObject

+ (void)setPassword:(NSString *)password;

+ (NSData *)encryptWithData:(NSData *)data userToken:(NSData *)userToken;

// when token is enabled, skip header
+ (NSData *)decryptWithData:(NSData *)data userToken:(NSData *)userToken;

@end
