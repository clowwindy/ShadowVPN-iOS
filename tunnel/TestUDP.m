//
//  TestUDP.m
//  ShadowVPN
//
//  Created by clowwindy on 8/9/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

#include <netdb.h>
#include <arpa/inet.h>
#include <netinet/ip.h>
#import "TestUDP.h"


@implementation TestUDP {
    dispatch_queue_t queue;
}

- (instancetype)init {
    self = [super init];
    queue = dispatch_queue_create("shadowvpn.dns", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [self run];
    });
    return self;
}

- (void)run {
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    addr.sin_port = htons(53);
    addr.sin_len = INET_ADDRSTRLEN;
    int r = bind(sockfd, (struct sockaddr *)&addr, INET_ADDRSTRLEN);
    NSLog(@"bind returns %d", r);
    NSLog(@"bind: %s", strerror(errno));
    char *buf = malloc(1500);
    struct sockaddr saddr;
    socklen_t saddrlen;
    while (1) {
        int r = recvfrom(sockfd, buf, 1500, 0, &saddr, &saddrlen);
        if (r > 0) {
            NSData *data = [[NSData alloc] initWithBytes:buf length:r];
            NSLog(@"%@", data);
        } else {
            NSLog(@"recvfrom returns %d", r);
            NSLog(@"recvfrom: %s", strerror(errno));
        }
    }

}

@end
