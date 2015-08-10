//
//  ChinaDNSRunner.h
//  ShadowVPN
//
//  Created by clowwindy on 8/9/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChinaDNSRunner : NSObject

- (instancetype)initWithDNS:(NSString *)dns;

+ (BOOL)checkWiFiNetwork;

@end
