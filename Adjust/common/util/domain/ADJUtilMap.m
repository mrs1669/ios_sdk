//
//  ADJUtilMap.m
//  AdjustV5
//
//  Created by Aditi Agrawal on 04/07/22.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJUtilMap.h"

#include <math.h>
#import "ADJStringMapBuilder.h"
#import "ADJUtilConv.h"
#import "ADJBooleanWrapper.h"
#import "ADJConstants.h"

@implementation ADJUtilMap

+ (void)injectIntoIoDataBuilderMap:(nonnull ADJStringMapBuilder *)ioDataMapBuilder
                               key:(nonnull NSString *)key
               ioValueSerializable:(nullable id<ADJIoValueSerializable>)ioValueSerializable {
    if (ioValueSerializable == nil) {
        return;
    }

    [ioDataMapBuilder addPairWithValue:[ioValueSerializable toIoValue] key:key];
}

+ (void)injectIntoIoDataBuilderMap:(nonnull ADJStringMapBuilder *)ioDataMapBuilder
                               key:(nonnull NSString *)key
                        constValue:(nullable NSString *)constValue {
    if (constValue == nil) {
        return;
    }

    [ioDataMapBuilder addPairWithConstValue:constValue key:key];
}

+ (void)injectIntoPackageParametersWithBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                           key:(nonnull NSString *)key
                 packageParamValueSerializable:(nullable id<ADJPackageParamValueSerializable>)packageParamValueSerializable {
    if (packageParamValueSerializable == nil) {
        return;
    }

    ADJNonEmptyString *_Nullable paramValue = [packageParamValueSerializable toParamValue];
    if (paramValue == nil) {
        return;
    }

    [parametersBuilder addPairWithValue:paramValue key:key];
}

+ (void)injectIntoPackageParametersWithBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                           key:(nonnull NSString *)key
                                    constValue:(nullable NSString *)constValue {
    if (constValue == nil) {
        return;
    }

    [parametersBuilder addPairWithConstValue:constValue key:key];
}

+ (nullable ADJStringMap *)mergeMapsWithBaseMap:(nullable ADJStringMap *)baseMap
                                 overwritingMap:(nullable ADJStringMap *)overwritingMap {
    if (baseMap == nil || [baseMap isEmpty]) {
        return overwritingMap;
    }

    if (overwritingMap == nil || [overwritingMap isEmpty]) {
        return baseMap;
    }

    ADJStringMapBuilder *_Nonnull mergedMap =
    [[ADJStringMapBuilder alloc] initWithStringMap:baseMap];

    [mergedMap addAllPairsWithStringMap:overwritingMap];

    return [[ADJStringMap alloc] initWithStringMapBuilder:mergedMap];
}

+ (nonnull ADJResult<NSString *> *)
    extractStringValueWithDictionary:(nullable NSDictionary *)dictionary
    key:(nonnull NSString *)key
{
    if (dictionary == nil) {
        return [ADJResult nilInputWithMessage:@"Cannot extract string value with nil dictionary"];
    }

    id _Nullable value = [dictionary objectForKey:key];
    if (value == nil) {
        return [ADJResult nilInputWithMessage:
                @"There is no value associated with key in dictionary that could be a string"];
    }

    if (! [value isKindOfClass:[NSString class]]) {
        return [ADJResult failWithMessage:
                [NSString stringWithFormat:@"Expected value of type String, instead found: %@",
                 NSStringFromClass([value class])]];
    }

    return [ADJResult okWithValue:(NSString *)value];
}

+ (nonnull ADJResult<NSNumber *> *)
    extractIntegerNumberWithDictionary:(nullable NSDictionary *)dictionary
    key:(nonnull NSString *)key
{
    if (dictionary == nil) {
        return [ADJResult nilInputWithMessage:@"Cannot extract integer value with nil dictionary"];
    }

    id _Nullable value = [dictionary objectForKey:key];
    if (value == nil) {
        return [ADJResult nilInputWithMessage:
                @"There is no value associated with key in dictionary that could be an int"];
    }

    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *_Nonnull number = (NSNumber *)value;
        // remainder of an integer that was cast to double when divided by one should be zero
        if (fmod(number.doubleValue, 1.0) == 0.0) {
            return [ADJResult okWithValue:number];
        }
        // otherwise, the original number was not an integer, but a double
        return [ADJResult failWithMessage:
                [NSString stringWithFormat:@"Number found to be non-integer: %@", number]];
    }

    return [ADJUtilConv convertToIntegerNumberWithStringValue:[value description]];
}

+ (nonnull ADJResult<NSNumber *> *)
    extractBooleanNumberWithDictionary:(nullable NSDictionary *)dictionary
    key:(nonnull NSString *)key
{
    if (dictionary == nil) {
        return [ADJResult
                nilInputWithMessage:@"Cannot extract boolean number from nil dictionary"];
    }

    id _Nullable value = [dictionary objectForKey:key];
    if (value == nil) {
        return [ADJResult
                nilInputWithMessage:@"There is no value associated with key"
                " in dictionary that could be a boolean number"];
    }

    if ([value isKindOfClass:[NSString class]]) {
        ADJResult<ADJBooleanWrapper *> *_Nonnull booleanStringResult =
            [ADJBooleanWrapper instanceFromString:(NSString *)value];
        if (booleanStringResult.fail != nil) {
            return [ADJResult failWithMessage:@"Cannot convert string boolean to boolean value"
                                          key:@"string fail"
                                    otherFail:booleanStringResult.fail];
        }
        return [ADJResult okWithValue:booleanStringResult.value.numberBoolValue];
    }

    if ([value isKindOfClass:[NSNumber class]]) {
        ADJResult<ADJBooleanWrapper *> *_Nonnull booleanNumberResult =
            [ADJBooleanWrapper instanceFromNumberBoolean:(NSNumber *)value];
        if (booleanNumberResult.fail != nil) {
            return [ADJResult failWithMessage:@"Cannot convert number boolean to boolean value"
                                          key:@"number fail"
                                    otherFail:booleanNumberResult.fail];
        }
        return [ADJResult okWithValue:booleanNumberResult.value.numberBoolValue];
    }

    return [ADJResult failWithMessage:@"Expected Bool from type String or Number"
                                  key:ADJLogActualKey
                          stringValue:NSStringFromClass([value class])];
}

+ (nonnull ADJResult<NSNumber *> *)
    extractDoubleNumberWithDictionary:(nullable NSDictionary *)dictionary
    key:(nonnull NSString *)key
{
    if (dictionary == nil) {
        return [ADJResult
                nilInputWithMessage:@"Cannot extract double number from nil dictionary"];
    }

    id _Nullable value = [dictionary objectForKey:key];

    if (value == nil) {
        return [ADJResult
                nilInputWithMessage:@"There is no value associated with key"
                " in dictionary that could be a double number"];
    }

    if ([value isKindOfClass:[NSNumber class]]) {
        return [ADJResult okWithValue:(NSNumber *)value];
    }

    return [ADJUtilConv convertToDoubleNumberWithStringValue:[value description]];
}

+ (nullable NSDictionary *)
    extractDictionaryValueWithDictionary:(nullable NSDictionary *)dictionary
    key:(nonnull NSString *)key
{
    if (dictionary == nil) {
        return nil;
    }

    id _Nullable value = [dictionary objectForKey:key];

    if (value == nil) {
        return nil;
    }

    if (! [value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    return (NSDictionary *)value;
}

@end
