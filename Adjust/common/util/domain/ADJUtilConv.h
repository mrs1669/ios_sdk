//
//  ADJUtilConv.h
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJStringMap.h"
#import "ADJOptionalFailsNN.h"
#import "ADJInputLogMessageData.h"
#import "ADJUtilMap.h"

@interface ADJUtilConv : NSObject

+ (NSTimeInterval)convertToSecondsWithMilliseconds:(NSUInteger)milliseconds;

// string to numbers
+ (nonnull ADJResult<NSNumber *> *)
    convertToIntegerNumberWithStringValue:(nonnull NSString *)stringValue;
+ (nonnull ADJResult<NSNumber *> *)
    convertToLLNumberWithStringValue:(nonnull NSString *)stringValue;
+ (nonnull ADJResult<NSNumber *> *)
    convertToDoubleNumberWithStringValue:(nonnull NSString *)stringValue;

// to and from base 64
+ (nullable NSString *)convertToBase64StringWithDataValue:(nullable NSData *)dataValue;
+ (nullable NSData *)convertToDataWithBase64String:(nullable NSString *)base64String;

// string map convertions
+ (nonnull ADJOptionalFailsNN<ADJResult<ADJStringMap *> *> *)
    convertToStringMapWithKeyValueArray:(nullable NSArray<NSString *> *)keyValueArray;

// nameKeyValueArray maps [name, key, value] to <name, <key, value>>
//  value can be either string or boolean
+ (nonnull ADJOptionalFailsNN<ADJResult<ADJNonEmptyString *> *> *)
    jsonStringFromNameKeyValueArray:
    (nullable NSArray<NSString *> *)nameKeyValueArray;

@end
