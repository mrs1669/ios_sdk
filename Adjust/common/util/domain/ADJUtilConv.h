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

+ (nonnull ADJResult<NSNumber *> *)
    convertToIntegerNumberWithStringValue:(nonnull NSString *)stringValue;
+ (nonnull ADJResult<NSNumber *> *)
    convertToLLNumberWithStringValue:(nonnull NSString *)stringValue;
+ (nonnull ADJResult<NSNumber *> *)
    convertToDoubleNumberWithStringValue:(nonnull NSString *)stringValue;

+ (nullable NSString *)convertToBase64StringWithDataValue:(nullable NSData *)dataValue;
+ (nullable NSData *)convertToDataWithBase64String:(nullable NSString *)base64String;

+ (nonnull ADJResult<NSData *> *)
    convertToJsonDataWithJsonFoundationValue:(nonnull id)jsonFoundationValue;
+ (nonnull ADJResult<id> *)
    convertToFoundationObjectWithJsonString:(nonnull NSString *)jsonString;
+ (nonnull ADJResult<id> *)convertToJsonFoundationValueWithJsonData:(nonnull NSData *)jsonData;

+ (nonnull id)convertToFoundationObject:(nonnull id)foundationObject;

+ (nonnull ADJOptionalFailsNN<ADJResult<ADJStringMap *> *> *)
    convertToStringMapWithKeyValueArray:(nullable NSArray<NSString *> *)keyValueArray;

+ (nonnull ADJOptionalFailsNN<ADJResult<NSDictionary<NSString *, ADJStringKeyDict> *> *> *)
    convertToStringMapCollectionByNameBuilderWithNameKeyValueArray:
        (nullable NSArray<NSString *> *)nameKeyStringValueArray;

+ (nonnull ADJOptionalFailsNN<ADJResult<NSDictionary<NSString *, ADJStringKeyDict> *> *> *)
    convertToNumberBooleanMapCollectionByNameBuilderWithNameKeyValueArray:
        (nullable NSArray *)nameKeyNumberBooleanValueArray;

@end
