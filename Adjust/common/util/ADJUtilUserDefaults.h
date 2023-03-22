//
//  ADJUtilUserDefaults.h
//  Adjust
//
//  Created by Pedro Silva on 25.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJUtilUserDefaults : NSObject
// instantiation
- (nullable instancetype)init NS_UNAVAILABLE;

// public api
+ (nullable NSNumber *)numberBoolWithKey:(nonnull NSString *)key;
+ (nullable NSString *)stringWithKey:(nonnull NSString *)key;
+ (nullable NSData *)dataWithKey:(nonnull NSString *)key;
+ (nullable NSDate *)dateWithKey:(nonnull NSString *)key;
+ (nullable NSURL *)urlWithKey:(nonnull NSString *)key;
+ (nullable NSDictionary *)dictionaryWithKey:(nonnull NSString *)key;

+ (void)setStringValue:(nonnull NSString *)stringValue key:(nonnull NSString *)key;

+ (void)removeObjectWithKey:(nonnull NSString *)key;

@end
