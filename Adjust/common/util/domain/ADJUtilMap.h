//
//  ADJUtilMap.h
//  AdjustV5
//
//  Created by Aditi Agrawal on 04/07/22.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJStringMapBuilder.h"
#import "ADJIoValueSerializable.h"
#import "ADJPackageParamValueSerializable.h"
#import "ADJStringMap.h"

@interface ADJUtilMap : NSObject

+ (void)injectIntoIoDataBuilderMap:(nonnull ADJStringMapBuilder *)ioDataMapBuilder
                               key:(nonnull NSString *)key
               ioValueSerializable:(nullable id<ADJIoValueSerializable>)ioValueSerializable;

+ (void)injectIntoIoDataBuilderMap:(nonnull ADJStringMapBuilder *)ioDataMapBuilder
                               key:(nonnull NSString *)key
                        constValue:(nullable NSString *)constValue;

+ (void)injectIntoPackageParametersWithBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                           key:(nonnull NSString *)key
                 packageParamValueSerializable:(nullable id<ADJPackageParamValueSerializable>)packageParamValueSerializable;

+ (void)injectIntoPackageParametersWithBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                           key:(nonnull NSString *)key
                                    constValue:(nullable NSString *)constValue;

+ (nullable ADJStringMap *)mergeMapsWithBaseMap:(nullable ADJStringMap *)baseMap
                                 overwritingMap:(nullable ADJStringMap *)overwritingMap;

+ (nonnull ADJResult<NSString *> *)
    extractStringValueWithDictionary:(nullable NSDictionary *)dictionary
    key:(nonnull NSString *)key;

+ (nonnull ADJResult<NSNumber *> *)
    extractIntegerNumberWithDictionary:(nullable NSDictionary *)dictionary
    key:(nonnull NSString *)key;

+ (nonnull ADJResult<NSNumber *> *)
    extractBooleanNumberWithDictionary:(nullable NSDictionary *)dictionary
    key:(nonnull NSString *)key;

+ (nonnull ADJResult<NSNumber *> *)
    extractDoubleNumberWithDictionary:(nullable NSDictionary *)dictionary
    key:(nonnull NSString *)key;

+ (nullable NSDictionary *)extractDictionaryValueWithDictionary:(nullable NSDictionary *)dictionary
                                                            key:(nonnull NSString *)key;

@end
