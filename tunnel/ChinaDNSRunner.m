//
//  ChinaDNSRunner.m
//  ShadowVPN
//
//  Created by clowwindy on 8/9/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

#import "chinadns.h"

#import "ChinaDNSRunner.h"

#define MAX_ARG 64
#define ADD_ARGV(arg) do { argv[argc] = arg; argc++; } while (0)

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
    NSLog(@"%s", iplistPath);
    NSLog(@"%s", chnroutesPath);
    
    ADD_ARGV("chinadns");
    ADD_ARGV("-l");
    ADD_ARGV(iplistPath);
    ADD_ARGV("-c");
    ADD_ARGV(chnroutesPath);
    ADD_ARGV("-b");
    ADD_ARGV("127.0.0.1");
    ADD_ARGV("-p");
    ADD_ARGV("53");
    ADD_ARGV("-v");
    int r = chinadns_main(argc, argv);
    free(iplistPath);
    free(chnroutesPath);
    exit(r);
}


@end
