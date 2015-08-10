//
//  ChinaDNSRunner.m
//  ShadowVPN
//
//  Created by clowwindy on 8/9/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

#include <ifaddrs.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#import "chinadns.h"

#import "ChinaDNSRunner.h"

#define MAX_ARG 64
#define ADD_ARGV(arg) do { argv[argc] = arg; argc++; } while (0)

static BOOL _wifiStatus;

@implementation ChinaDNSRunner {
    NSString *_dns;
    dispatch_queue_t _queue;
}

- (instancetype)initWithDNS:(NSString *)dns {
    self = [super init];
    if (self) {
        _dns = [dns copy];
        _queue = dispatch_queue_create("shadowvpn.dns", DISPATCH_QUEUE_SERIAL);
        dispatch_async(_queue, ^{
            [self run];
        });
    }

    return self;
}


- (void)run {
    int argc = 0;
    char *(argv)[MAX_ARG];
    
    char *iplistPath = strdup([[[NSBundle mainBundle] pathForResource:@"iplist" ofType:@"txt"] cStringUsingEncoding:NSUTF8StringEncoding]);
    char *chnroutesPath = strdup([[[NSBundle mainBundle] pathForResource:@"chnroutes" ofType:@"txt"] cStringUsingEncoding:NSUTF8StringEncoding]);
    char *dns = strdup([_dns cStringUsingEncoding:NSUTF8StringEncoding]);
    NSLog(@"%s", iplistPath);
    NSLog(@"%s", chnroutesPath);
    
    ADD_ARGV("chinadns");
    ADD_ARGV("-l");
    ADD_ARGV(iplistPath);
    ADD_ARGV("-c");
    ADD_ARGV(chnroutesPath);
    ADD_ARGV("-s");
    ADD_ARGV(dns);
    ADD_ARGV("-b");
    ADD_ARGV("127.0.0.1");
    ADD_ARGV("-p");
    ADD_ARGV("53");
    ADD_ARGV("-v");
    int r = chinadns_main(argc, argv);
    free(iplistPath);
    free(chnroutesPath);
    free(dns);
    exit(r);
}

+ (BOOL)checkWiFiNetwork {
    struct ifaddrs* interfaces = NULL;
    struct ifaddrs* temp_addr = NULL;
    BOOL found = NO;
    
    NSInteger success = getifaddrs(&interfaces);
    if (success == 0)
    {
        temp_addr = interfaces;
        while (temp_addr != NULL)
        {
            if (temp_addr->ifa_addr->sa_family == AF_INET)
            {
                NSString* name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString* address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
//                NSLog(@"%@ %@", name, address);
                if ([name rangeOfString:@"en"].location == 0) {
                    found = YES;
                    break;
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    if (_wifiStatus != found) {
        remote_recreate_required = 1;
    }
    _wifiStatus = found;
    freeifaddrs(interfaces);
    return found;
}

@end
