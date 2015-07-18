//
//  SVCrypto.m
//  ShadowVPN
//
//  Created by clowwindy on 7/18/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

#import "SVCrypto.h"
#import "crypto.h"

static const int max_mtu = 8192;
static unsigned char tun_buf[max_mtu + SHADOWVPN_ZERO_BYTES];
static unsigned char udp_buf[max_mtu + SHADOWVPN_ZERO_BYTES];

@implementation SVCrypto

+ (void)load {
  crypto_init();
  bzero(tun_buf, SHADOWVPN_ZERO_BYTES);
  bzero(udp_buf, SHADOWVPN_ZERO_BYTES);
}

+ (void)setPassword:(NSString *)password {
  crypto_set_password([password cStringUsingEncoding:NSUTF8StringEncoding], password.length);
}

+ (NSData *)encrypt:(NSData *)data {
  if (data.length > max_mtu) {
    return nil;
  }
  memcpy(tun_buf + SHADOWVPN_ZERO_BYTES, data.bytes, data.length);
  crypto_encrypt(udp_buf, tun_buf, data.length);
  NSData *result = [NSData dataWithBytes:udp_buf + SHADOWVPN_PACKET_OFFSET length:data.length + SHADOWVPN_OVERHEAD_LEN];
  return result;
}

+ (NSData *)decrypt:(NSData *)data {
  if (data.length > max_mtu || data.length < SHADOWVPN_OVERHEAD_LEN) {
    return nil;
  }
  memcpy(udp_buf + SHADOWVPN_PACKET_OFFSET, data.bytes, data.length);
  crypto_decrypt(tun_buf, udp_buf, data.length - SHADOWVPN_OVERHEAD_LEN);
  NSData *result = [NSData dataWithBytes:tun_buf + SHADOWVPN_ZERO_BYTES length:data.length - SHADOWVPN_OVERHEAD_LEN];
  return result;
}

@end
