//
//  SVCrypto.h
//  ShadowVPN
//
//  Created by clowwindy on 7/18/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVCrypto : NSObject

+ (void)setPassword: (NSString *)password;

+ (NSData *)encrypt: (NSData *)data;

+ (NSData *)decrypt: (NSData *)data;

@end
