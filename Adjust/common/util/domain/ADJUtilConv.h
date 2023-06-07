//
//  ADJUtilConv.h
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJStringMap.h"
#import "ADJResultNN.h"
#import "ADJOptionalFailsNN.h"
#import "ADJInputLogMessageData.h"
#import "ADJUtilMap.h"

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

+ (nonnull ADJResultNN<NSData *> *)
    convertToJsonDataWithJsonFoundationValue:(nonnull id)jsonFoundationValue;
+ (nonnull ADJResultNN<id> *)
    convertToFoundationObjectWithJsonString:(nonnull NSString *)jsonString;
+ (nonnull ADJResultNN<id> *)convertToJsonFoundationValueWithJsonData:(nonnull NSData *)jsonData;

+ (nonnull id)convertToFoundationObject:(nonnull id)foundationObject;

+ (nonnull ADJOptionalFailsNN<ADJResultNL<ADJStringMap *> *> *)
    convertToStringMapWithKeyValueArray:(nullable NSArray<NSString *> *)keyValueArray;

+ (nonnull ADJOptionalFailsNN<ADJResultNL<NSDictionary<NSString *, ADJStringKeyDict> *> *> *)
    convertToStringMapCollectionByNameBuilderWithNameKeyValueArray:
        (nullable NSArray<NSString *> *)nameKeyStringValueArray;

+ (nonnull ADJOptionalFailsNN<ADJResultNL<NSDictionary<NSString *, ADJStringKeyDict> *> *> *)
    convertToNumberBooleanMapCollectionByNameBuilderWithNameKeyValueArray:
        (nullable NSArray *)nameKeyNumberBooleanValueArray;

@end
