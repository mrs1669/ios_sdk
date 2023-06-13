//
//  ADJUtilConv.h
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJStringMap.h"
#import "ADJOptionalFails.h"
#import "ADJLogger.h"

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
+ (nullable ADJStringMap *)
    clientStringMapWithKeyValueArray:(nullable NSArray *)keyValueArray
    logger:(nonnull ADJLogger *)logger
    processingFailMessage:(nonnull NSString *)processingFailMessage
    addingFailMessage:(nonnull NSString *)addingFailMessage
    emptyFailMessage:(nonnull NSString *)emptyFailMessage;

// nameKeyValueArray maps [name, key, value] to <name, <key, value>>
// name, key and value need to be string
+ (nonnull ADJOptionalFails<ADJResult<ADJNonEmptyString *> *> *)
    jsonStringFromNameKeyStringValueArray:
    (nullable NSArray<NSString *> *)nameKeyStringValueArray;
// name and key need to be string, value needs to boolean
+ (nonnull ADJOptionalFails<ADJResult<ADJNonEmptyString *> *> *)
    jsonStringFromNameKeyBooleanValueArray:
    (nullable NSArray<NSString *> *)nameKeyBooleanValueArray;

@end
