//
//  SMS4.m
//  SMS4
//
//  Created by 张旭 on 15/3/2.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#import "SMS4.h"

#define ROUND 32

static uint8_t sbox[256] = {
    0xd6, 0x90, 0xe9, 0xfe, 0xcc, 0xe1, 0x3d, 0xb7, 0x16, 0xb6, 0x14, 0xc2, 0x28, 0xfb, 0x2c, 0x05,
    0x2b, 0x67, 0x9a, 0x76, 0x2a, 0xbe, 0x04, 0xc3, 0xaa, 0x44, 0x13, 0x26, 0x49, 0x86, 0x06, 0x99,
    0x9c, 0x42, 0x50, 0xf4, 0x91, 0xef, 0x98, 0x7a, 0x33, 0x54, 0x0b, 0x43, 0xed, 0xcf, 0xac, 0x62,
    0xe4, 0xb3, 0x1c, 0xa9, 0xc9, 0x08, 0xe8, 0x95, 0x80, 0xdf, 0x94, 0xfa, 0x75, 0x8f, 0x3f, 0xa6,
    0x47, 0x07, 0xa7, 0xfc, 0xf3, 0x73, 0x17, 0xba, 0x83, 0x59, 0x3c, 0x19, 0xe6, 0x85, 0x4f, 0xa8,
    0x68, 0x6b, 0x81, 0xb2, 0x71, 0x64, 0xda, 0x8b, 0xf8, 0xeb, 0x0f, 0x4b, 0x70, 0x56, 0x9d, 0x35,
    0x1e, 0x24, 0x0e, 0x5e, 0x63, 0x58, 0xd1, 0xa2, 0x25, 0x22, 0x7c, 0x3b, 0x01, 0x21, 0x78, 0x87,
    0xd4, 0x00, 0x46, 0x57, 0x9f, 0xd3, 0x27, 0x52, 0x4c, 0x36, 0x02, 0xe7, 0xa0, 0xc4, 0xc8, 0x9e,
    0xea, 0xbf, 0x8a, 0xd2, 0x40, 0xc7, 0x38, 0xb5, 0xa3, 0xf7, 0xf2, 0xce, 0xf9, 0x61, 0x15, 0xa1,
    0xe0, 0xae, 0x5d, 0xa4, 0x9b, 0x34, 0x1a, 0x55, 0xad, 0x93, 0x32, 0x30, 0xf5, 0x8c, 0xb1, 0xe3,
    0x1d, 0xf6, 0xe2, 0x2e, 0x82, 0x66, 0xca, 0x60, 0xc0, 0x29, 0x23, 0xab, 0x0d, 0x53, 0x4e, 0x6f,
    0xd5, 0xdb, 0x37, 0x45, 0xde, 0xfd, 0x8e, 0x2f, 0x03, 0xff, 0x6a, 0x72, 0x6d, 0x6c, 0x5b, 0x51,
    0x8d, 0x1b, 0xaf, 0x92, 0xbb, 0xdd, 0xbc, 0x7f, 0x11, 0xd9, 0x5c, 0x41, 0x1f, 0x10, 0x5a, 0xd8,
    0x0a, 0xc1, 0x31, 0x88, 0xa5, 0xcd, 0x7b, 0xbd, 0x2d, 0x74, 0xd0, 0x12, 0xb8, 0xe5, 0xb4, 0xb0,
    0x89, 0x69, 0x97, 0x4a, 0x0c, 0x96, 0x77, 0x7e, 0x65, 0xb9, 0xf1, 0x09, 0xc5, 0x6e, 0xc6, 0x84,
    0x18, 0xf0, 0x7d, 0xec, 0x3a, 0xdc, 0x4d, 0x20, 0x79, 0xee, 0x5f, 0x3e, 0xd7, 0xcb, 0x39, 0x48
};

static uint32_t fk[4] = {
    0xa3b1bac6, 0x56aa3350, 0x677d9197, 0xb27022dc
};

static uint32_t ck[32] = {
    0x00070e15, 0x1c232a31, 0x383f464d, 0x545b6269,
    0x70777e85, 0x8c939aa1, 0xa8afb6bd, 0xc4cbd2d9,
    0xe0e7eef5, 0xfc030a11, 0x181f262d, 0x343b4249,
    0x50575e65, 0x6c737a81, 0x888f969d, 0xa4abb2b9,
    0xc0c7ced5, 0xdce3eaf1, 0xf8ff060d, 0x141b2229,
    0x30373e45, 0x4c535a61, 0x686f767d, 0x848b9299,
    0xa0a7aeb5, 0xbcc3cad1, 0xd8dfe6ed, 0xf4fb0209,
    0x10171e25, 0x2c333a41, 0x484f565d, 0x646b7279
};

@implementation SMS4

- (NSString*) Encrypt:(NSString *)plainText withkey:(NSString *)key {
    
    if ([plainText length] != 32) {
        return nil;
    }
    if ([key length] != 32) {
        return nil;
    }
    
    uint32_t roundkey[32] = {0};
    uint32_t numkey[4];
    uint32_t numplaintext[4];
    
    for (int i = 0; i < [plainText length]-1; i += 8) {
        NSString* hexString = [plainText substringWithRange:NSMakeRange(i, 8)];
        NSScanner* scanner = [[NSScanner alloc] initWithString:hexString];
        [scanner scanHexInt:&numplaintext[i/8]];
    }
    
    for (int i = 0; i < [key length]-1; i += 8) {
        NSString* hexString = [key substringWithRange:NSMakeRange(i, 8)];
        NSScanner* scanner = [[NSScanner alloc] initWithString:hexString];
        [scanner scanHexInt:&numkey[i/8]];
    }
    
    [self GenerateRoundKey:numkey roundKey:roundkey];
        
    for (int i = 0; i < 32; ++i) {
        [self RoundFunc: numplaintext withSubkey:roundkey[i]];
    }
        
    [self Reverse:numplaintext];
    
    
    NSString* encryptedText = [NSString stringWithFormat:@"%08X%08X%08X%08X",
                              numplaintext[0]&0xffffffff, numplaintext[1]&0xffffffff,
                              numplaintext[2]&0xffffffff, numplaintext[3]&0xffffffff];
    
    return [encryptedText lowercaseString];
}

- (NSString*) Decrypt:(NSString *)cipherText withkey:(NSString *)key {
    
    if ([cipherText length] != 32) {
        return nil;
    }
    if ([key length] != 32) {
        return nil;
    }
    uint32_t roundkey[32] = {0};
    uint32_t numkey[4];
    uint32_t numciphertext[4];
    
    for (int i = 0; i < [cipherText length]-1; i += 8) {
        NSString* hexString = [cipherText substringWithRange:NSMakeRange(i, 8)];
        NSScanner* scanner = [[NSScanner alloc] initWithString:hexString];
        [scanner scanHexInt:&numciphertext[i/8]];
    }
    
    for (int i = 0; i < [key length]-1; i += 8) {
        NSString* hexString = [key substringWithRange:NSMakeRange(i, 8)];
        NSScanner* scanner = [[NSScanner alloc] initWithString:hexString];
        [scanner scanHexInt:&numkey[i/8]];
    }
    
    [self GenerateRoundKey:numkey roundKey:roundkey];
    
    for (int i = 0; i < 32; ++i) {
        [self RoundFunc:numciphertext withSubkey:roundkey[31-i]];
    }
    
    [self Reverse:numciphertext];
    
    NSString* descryptedText = [NSString stringWithFormat:@"%08X%08X%08X%08X",
                                numciphertext[0]&0xffffffff, numciphertext[1]&0xffffffff,
                                numciphertext[2]&0xffffffff, numciphertext[3]&0xffffffff];
    
    return [descryptedText lowercaseString];
}

- (void) GenerateRoundKey: (uint32_t const*)key roundKey: (uint32_t*)roundKey {
    
    uint32_t buf[4];
    uint32_t* prk = (uint32_t*)roundKey;
    
    memcpy(buf, key, sizeof(uint32_t)*4);
    
    buf[0] ^= fk[0];
    buf[1] ^= fk[1];
    buf[2] ^= fk[2];
    buf[3] ^= fk[3];
    
    
    for (int i = 0; i < 32; ++i) {
        prk[i] = buf[0] ^ [self TTrans2:(buf[1]^buf[2]^buf[3]^ck[i])];
        buf[0] = buf[1];
        buf[1] = buf[2];
        buf[2] = buf[3];
        buf[3] = prk[i];
    }
}

- (uint32_t) LTrans1: (uint32_t)x {
    return (x ^ [self RotateLeft:x offset:2] ^ [self RotateLeft:x offset:10]
            ^ [self RotateLeft:x offset:18] ^ [self RotateLeft:x offset:24]);
}

- (uint32_t) LTrans2: (uint32_t)x {
    return (x ^ [self RotateLeft:x offset:13] ^ [self RotateLeft:x offset:23]);
}

- (uint32_t) TTrans1: (uint32_t)x {
    return [self LTrans1:[self Substitute:x]];
}

- (uint32_t) TTrans2: (uint32_t)x {
    return [self LTrans2:[self Substitute:x]];
}

- (uint32_t) RotateLeft: (uint32_t)x offset: (uint8_t)offset {
    return ((x << offset) | (x >> (32-offset)));
}

- (uint32_t) Substitute: (uint32_t)x {
    uint8_t* px = (uint8_t*)&x;
    
    px[0] = sbox[px[0]];
    px[1] = sbox[px[1]];
    px[2] = sbox[px[2]];
    px[3] = sbox[px[3]];
    
    return x;
}

- (void) RoundFunc: (uint32_t*)input withSubkey: (uint32_t)sub_key {
    uint32_t tmp = input[0];
    
    input[0] = input[1];
    input[1] = input[2];
    input[2] = input[3];
    input[3] = tmp ^ [self TTrans1:(input[0] ^ input[1] ^ input[2] ^ sub_key)];
}

- (void) Reverse: (uint32_t*)input {
    uint32_t tmp;
    tmp = input[0];
    input[0] = input[3];
    input[3] = tmp;
    
    tmp = input[1];
    input[1] = input[2];
    input[2] = tmp;
}

@end








