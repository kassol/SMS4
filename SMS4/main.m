//
//  main.m
//  SMS4
//
//  Created by 张旭 on 15/3/2.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMS4.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        SMS4* sms4 = [[SMS4 alloc] init];
        
        NSString* plainText = @"0123456789abcdeffedcba9876543210";
        
        NSString* key = @"0123456789abcdeffedcba9876543210";
        
        //测试加密
        NSString* result1 = [sms4 Encrypt:plainText withkey:key];
        
        NSLog(@"plainText: %@", plainText);
        NSLog(@"key: %@", key);
        NSLog(@"The encrypted text: %@", result1);
        
        NSString* cipherText = @"681edf34d206965e86b3e94f536e4246";
        
        if ([result1 isEqualToString:cipherText]) {
            NSLog(@"The encrypt result is true.");
        }
        
        //测试解密
        NSString* result2 = [sms4 Decrypt:cipherText withkey:key];
        
        NSLog(@"cipherText: %@", cipherText);
        NSLog(@"key: %@", key);
        NSLog(@"The decrypted text: %@", result2);
        
        if ([result2 isEqualToString:plainText]) {
            NSLog(@"The Decrypt result is true.");
        }
        
        //测试1000000次加密
        result1 = plainText;
        
        for (int i = 0; i < 1000000; ++i) {
            result1 = [sms4 Encrypt:result1 withkey:key];
        }
        NSLog(@"1000000's result: %@", result1);
        
        NSString* millionEnctyptResult = @"595298c7c6fd271f0402f804c33d3f66";
        if ([result1 isEqualToString:millionEnctyptResult]) {
            NSLog(@"1000000's encrypt result is true.");
        }
    }
    return 0;
}
