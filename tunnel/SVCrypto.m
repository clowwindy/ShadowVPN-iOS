//
//  SVCrypto.m
//  ShadowVPN
//
//  Created by clowwindy on 7/18/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

#import "SVCrypto.h"
#import "crypto.h"

static const int max_mtu = 2048;
static const int sv_buf_size = max_mtu + SHADOWVPN_ZERO_BYTES + SHADOWVPN_USERTOKEN_LEN;

static NSString *kTunBufKey = @"SVTunBuf";
static NSString *kUdpBufKey = @"SVUdpBuf";

@implementation SVCrypto

+ (void)load {
    crypto_init();
}

+ (void)setPassword:(NSString *)password {
    crypto_set_password([password cStringUsingEncoding:NSUTF8StringEncoding], password.length);
}

+ (NSMutableData *)tunbuf {
    NSMutableData *buf = [[NSThread currentThread] threadDictionary][kTunBufKey];
    if (buf == nil) {
        buf = [[NSMutableData alloc] initWithLength:sv_buf_size];
        [[NSThread currentThread] threadDictionary][kTunBufKey] = buf;
    }
    return buf;
}

+ (NSMutableData *)udpbuf {
    NSMutableData *buf = [[NSThread currentThread] threadDictionary][kUdpBufKey];
    if (buf == nil) {
        buf = [[NSMutableData alloc] initWithLength:sv_buf_size];
        [[NSThread currentThread] threadDictionary][kUdpBufKey] = buf;
    }
    return buf;
}

+ (NSData *)encryptWithData:(NSData *)data userToken:(NSData *)userToken {
    int usertoken_len = 0;
    if (data.length > max_mtu) {
        return nil;
    }
    unsigned char *tun_buf = [[SVCrypto tunbuf] mutableBytes];
    unsigned char *udp_buf = [[SVCrypto udpbuf] mutableBytes];
    
    if (userToken) {
        NSAssert(userToken.length == SHADOWVPN_USERTOKEN_LEN, @"invalid user token length");
        usertoken_len = SHADOWVPN_USERTOKEN_LEN;
        memcpy(tun_buf + SHADOWVPN_ZERO_BYTES, userToken.bytes, userToken.length);
    }
    memcpy(tun_buf + SHADOWVPN_ZERO_BYTES + usertoken_len, data.bytes, data.length);
    crypto_encrypt(udp_buf, tun_buf, usertoken_len + data.length);
    NSData *result = [NSData dataWithBytes:udp_buf + SHADOWVPN_PACKET_OFFSET length:SHADOWVPN_OVERHEAD_LEN + usertoken_len + data.length];
    return result;
}

+ (NSData *)decryptWithData:(NSData *)data userToken:(NSData *)userToken {
    int usertoken_len = 0;
    if (data.length > max_mtu || data.length < SHADOWVPN_OVERHEAD_LEN) {
        return nil;
    }
    unsigned char *tun_buf = [[SVCrypto tunbuf] mutableBytes];
    unsigned char *udp_buf = [[SVCrypto udpbuf] mutableBytes];
    if (userToken) {
        NSAssert(userToken.length == SHADOWVPN_USERTOKEN_LEN, @"invalid user token length");
        usertoken_len = SHADOWVPN_USERTOKEN_LEN;
        // TODO compare user token and log warnings
    }
    memcpy(udp_buf + SHADOWVPN_PACKET_OFFSET, data.bytes, data.length);
    crypto_decrypt(tun_buf, udp_buf, data.length - SHADOWVPN_OVERHEAD_LEN);
    NSData *result = [NSData dataWithBytes:tun_buf + SHADOWVPN_ZERO_BYTES + usertoken_len length:data.length - SHADOWVPN_OVERHEAD_LEN - usertoken_len];
    return result;
}

@end
