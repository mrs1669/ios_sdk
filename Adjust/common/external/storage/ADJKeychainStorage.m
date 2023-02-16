//
//  ADJKeychainStorage.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJKeychainStorage.h"

#include <Security/SecItem.h>
#include <dlfcn.h>

@implementation ADJKeychainStorage
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
{
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"ADJKeychainStorage"];

    return self;
}

#pragma mark Public API
- (nullable ADJNonEmptyString *)valueInGenericPasswordKeychainWithKey:(nonnull NSString *)key
                                                               service:(nonnull NSString *)service
{
    NSMutableDictionary *_Nonnull keychainItem = [self keychainItemForKey:key service:service];

    keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;

    CFDictionaryRef result = nil;
    OSStatus status =
        SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem,
                            (CFTypeRef *)&result);
    if (status != noErr) {
        return nil;
    }

    NSDictionary *resultDict = (__bridge_transfer NSDictionary *)result;
    NSData *data = resultDict[(__bridge id)kSecValueData];
    if (! data) {
        return nil;
    }

    NSString *_Nonnull stringValue =
        [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    ADJResultNN<ADJNonEmptyString *> *_Nonnull stringResult =
        [ADJNonEmptyString instanceFromString:stringValue];
    if (stringResult.failMessage != nil) {
        [self.logger debugDev:@"Invalid value in generic password keychain"
                    valueName:key
                  failMessage:stringResult.failMessage
                    issueType:ADJIssueExternalApi];
        return nil;
    }

    return stringResult.value;
}

- (BOOL)setGenericPasswordKeychainWithKey:(nonnull NSString *)key
                                  service:(nonnull NSString *)service
                                    value:(nonnull ADJNonEmptyString *)value
{
    NSMutableDictionary *_Nonnull keychainItem = [self keychainItemForKey:key service:service];

    keychainItem[(__bridge id)kSecValueData] =
        [value.stringValue dataUsingEncoding:NSUTF8StringEncoding];

    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);

    if (status != noErr) {
        return NO;
    }

    // confirm it can read the same written value
    return [value isEqual:[self valueInGenericPasswordKeychainWithKey:key service:service]];
}

- (nonnull NSMutableDictionary *)keychainItemForKey:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];

    keychainItem[(__bridge id)kSecAttrAccessible] =
        (__bridge id)kSecAttrAccessibleAfterFirstUnlock;

    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccount] = key;
    keychainItem[(__bridge id)kSecAttrService] = service;

    return keychainItem;
}

@end
