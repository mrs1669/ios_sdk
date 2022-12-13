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

+ (nullable NSNumber *)convertToIntegerNumberWithStringValue:(nullable NSString *)stringValue;
+ (nullable NSNumber *)convertToLLNumberWithStringValue:(nullable NSString *)stringValue;
+ (nullable NSNumber *)convertToDoubleNumberWithStringValue:(nonnull NSString *)stringValue;

+ (nullable NSString *)convertToBase64StringWithDataValue:(nullable NSData *)dataValue;
+ (nullable NSData *)convertToDataWithBase64String:(nullable NSString *)base64String;

+ (nullable NSData *)convertToJsonDataWithJsonFoundationValue:(nonnull id)jsonFoundationValue
                                                     errorPtr:(NSError * _Nullable * _Nonnull)errorPtr;
+ (nullable id)convertToJsonFoundationValueWithJsonData :(nonnull NSData *)jsonData
                                                errorPtr:(NSError * _Nullable * _Nonnull)errorPtr;

+ (nonnull id)convertToFoundationObject:(nonnull id)foundationObject;

+ (nullable ADJStringMap *)convertToStringMapWithKeyValueArray:(nullable NSArray<NSString *> *)keyValueArray
                                             sourceDescription:(nonnull NSString *)sourceDescription
                                                        logger:(nonnull ADJLogger *)logger;

+ (nullable NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSString *> *> *)
convertToMapCollectionByNameBuilderWithKeyValueArray:(nullable NSArray<NSString *> *)keyValueArray
sourceDescription:(nonnull NSString *)sourceDescription
logger:(nonnull ADJLogger *)logger;

@end
