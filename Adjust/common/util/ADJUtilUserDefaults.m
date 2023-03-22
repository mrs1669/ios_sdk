//
//  ADJUtilUserDefaults.m
//  Adjust
//
//  Created by Pedro Silva on 25.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJUtilUserDefaults.h"

@implementation ADJUtilUserDefaults
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
+ (nullable NSNumber *)numberBoolWithKey:(nonnull NSString *)key {
    id _Nullable numberBoolValue = [NSUserDefaults.standardUserDefaults objectForKey:key];

    if (numberBoolValue == nil || ! [numberBoolValue isKindOfClass:[NSNumber class]]) {
        return nil;
    }

    return (NSNumber *)numberBoolValue;
}

+ (nullable NSString *)stringWithKey:(nonnull NSString *)key {
    id _Nullable stringValue = [NSUserDefaults.standardUserDefaults objectForKey:key];

    if (stringValue == nil || ! [stringValue isKindOfClass:[NSString class]]) {
        return nil;
    }

    return (NSString *)stringValue;
}

+ (nullable NSData *)dataWithKey:(nonnull NSString *)key {
    id _Nullable dataValue = [NSUserDefaults.standardUserDefaults objectForKey:key];

    if (dataValue == nil || ! [dataValue isKindOfClass:[NSData class]]) {
        return nil;
    }

    return (NSData *)dataValue;
}

+ (nullable NSDate *)dateWithKey:(nonnull NSString *)key {
    id _Nullable dateValue = [NSUserDefaults.standardUserDefaults objectForKey:key];

    if (dateValue == nil || ! [dateValue isKindOfClass:[NSDate class]]) {
        return nil;
    }

    return (NSDate *)dateValue;
}

+ (nullable NSURL *)urlWithKey:(nonnull NSString *)key {
    return [NSUserDefaults.standardUserDefaults URLForKey:key];
}

+ (nullable NSDictionary *)dictionaryWithKey:(nonnull NSString *)key {
    return [NSUserDefaults.standardUserDefaults dictionaryForKey:key];
}

+ (void)removeObjectWithKey:(nonnull NSString *)key {
    [NSUserDefaults.standardUserDefaults removeObjectForKey:key];
}

+ (void)setStringValue:(nonnull NSString *)stringValue
                   key:(nonnull NSString *)key
{
    [NSUserDefaults.standardUserDefaults setObject:stringValue forKey:key];
}

@end
