//
//  ADJUtilObj.h
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJUtilObj : NSObject

+ (nullable NSString *)copyStringWithInput:(nullable id)inputValue;
+ (nonnull id)copyStringOrNSNullWithInput:(nullable id)inputValue;
+ (nullable id)copyObjectWithInput:(nullable id)inputValue
                       classObject:(nonnull Class)classObject;

+ (nonnull id)idOrNsNull:(nullable id)idObject;

+ (BOOL)objectEquals:(nullable id)one other:(nullable id)other;

+ (NSUInteger)objecNullableHash:(nullable id)object;

+ (nonnull NSString *)formatInlineKeyValuesWithName:
    (nonnull NSString *)name, ... NS_REQUIRES_NIL_TERMINATION;
+ (nonnull NSString *)
    formatInlineKeyValuesWithName:(nonnull NSString *)name
    stringKeyDictionary:(nonnull NSDictionary<NSString *, id> *)stringKeyDictionary;

+ (nonnull NSString *)
    formatNewlineKeyValuesWithName:(nonnull NSString *)name
    stringKeyDictionary:(nonnull NSDictionary<NSString *, id> *)stringKeyDictionary;

@end
