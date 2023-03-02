//
//  ADJUtilConv.h
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJStringMap.h"

@interface ADJUtilConv : NSObject

+ (NSTimeInterval)convertToSecondsWithMilliseconds:(NSUInteger)milliseconds;

+ (nonnull ADJResultNN<NSNumber *> *)
    convertToIntegerNumberWithStringValue:(nonnull NSString *)stringValue;
+ (nonnull ADJResultNN<NSNumber *> *)
    convertToLLNumberWithStringValue:(nonnull NSString *)stringValue;
+ (nonnull ADJResultNN<NSNumber *> *)
    convertToDoubleNumberWithStringValue:(nonnull NSString *)stringValue;

+ (nullable NSString *)convertToBase64StringWithDataValue:(nullable NSData *)dataValue;
+ (nullable NSData *)convertToDataWithBase64String:(nullable NSString *)base64String;

+ (nonnull ADJResultNL<NSData *> *)
    convertToJsonDataWithJsonFoundationValue:(nonnull id)jsonFoundationValue;
+ (nonnull ADJResultNL<id> *)
    convertToFoundationObjectWithJsonString:(nonnull NSString *)jsonString;
+ (nonnull ADJResultNL<id> *)convertToJsonFoundationValueWithJsonData:(nonnull NSData *)jsonData;

+ (nonnull id)convertToFoundationObject:(nonnull id)foundationObject;

+ (nullable ADJStringMap *)
    convertToStringMapWithKeyValueArray:(nullable NSArray<NSString *> *)keyValueArray
    sourceDescription:(nonnull NSString *)sourceDescription
    logger:(nonnull ADJLogger *)logger;

+ (nullable NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *)
    convertToStringMapCollectionByNameBuilderWithNameKeyValueArray:
        (nullable NSArray<NSString *> *)nameKeyStringValueArray
    sourceDescription:(nonnull NSString *)sourceDescription
    logger:(nonnull ADJLogger *)logger;

+ (nullable NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *)
    convertToNumberBooleanMapCollectionByNameBuilderWithNameKeyValueArray:
        (nullable NSArray *)nameKeyNumberBooleanValueArray
    sourceDescription:(nonnull NSString *)sourceDescription
    logger:(nonnull ADJLogger *)logger;

@end
