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

+ (nonnull ADJResultNL<NSString *> *)
    extractStringValueWithDictionary:(nullable NSDictionary *)dictionary
    key:(nonnull NSString *)key
{
    if (dictionary == nil) {
        return [ADJResultNL okWithoutValue];
    }

    id _Nullable value = [dictionary objectForKey:key];
    if (value == nil) {
        return [ADJResultNL okWithoutValue];
    }

    if (! [value isKindOfClass:[NSString class]]) {
        return [ADJResultNL failWithMessage:
                [NSString stringWithFormat:@"Expected value of type String, instead found: %@",
                 NSStringFromClass([value class])]];
    }

    return [ADJResultNL okWithValue:(NSString *)value];
}

+ (nonnull ADJResultNL<NSNumber *> *)
    extractIntegerNumberWithDictionary:(nullable NSDictionary *)dictionary
    key:(nonnull NSString *)key
{
    if (dictionary == nil) {
        return [ADJResultNL okWithoutValue];
    }

    id _Nullable value = [dictionary objectForKey:key];
    if (value == nil) {
        return [ADJResultNL okWithoutValue];
    }

    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *_Nonnull number = (NSNumber *)value;
        // remainder of an integer that was cast to double when divided by one should be zero
        if (fmod(number.doubleValue, 1.0) == 0.0) {
            return [ADJResultNL okWithValue:number];
        }
        // otherwise, the original number was not an integer, but a double
        return [ADJResultNL failWithMessage:
                [NSString stringWithFormat:@"Number found to be non-integer: %@", number]];
    }

    return [ADJResultNL instanceFromNN:^ADJResultNN * _Nonnull(NSString *_Nullable stringValue) {
        return [ADJUtilConv convertToIntegerNumberWithStringValue:stringValue];
    } nlValue:[value description]];
}

+ (nonnull ADJResultNL<NSNumber *> *)
    extractBooleanNumberWithDictionary:(nullable NSDictionary *)dictionary
    key:(nonnull NSString *)key
{
    if (dictionary == nil) {
        return [ADJResultNL okWithoutValue];
    }

    id _Nullable value = [dictionary objectForKey:key];
    if (value == nil) {
        return [ADJResultNL okWithoutValue];
    }

    if ([value isKindOfClass:[NSString class]]) {
        if ([[@(YES) description] isEqualToString:(NSString *)value]) {
            return [ADJResultNL okWithValue:@(YES)];
        }
        if ([[@(NO) description] isEqualToString:(NSString *)value]) {
            return [ADJResultNL okWithValue:@(NO)];
        }
        return [ADJResultNL failWithMessage:
                [NSString stringWithFormat:
                 @"Found String that does not mach either Bool: %@", value]];
    }

    if ([value isKindOfClass:[NSNumber class]]) {
        if ([@(YES) isEqualToNumber:(NSNumber *)value]) {
            return [ADJResultNL okWithValue:@(YES)];
        }
        if ([@(NO) isEqualToNumber:(NSNumber *)value]) {
            return [ADJResultNL okWithValue:@(NO)];
        }
        return [ADJResultNL failWithMessage:
                [NSString stringWithFormat:
                 @"Found Number that does not mach either Bool: %@", value]];
    }

    return [ADJResultNL failWithMessage:
            [NSString stringWithFormat:@"Expected Bool of type String or Number, instead found: %@",
             NSStringFromClass([value class])]];
}

+ (nonnull ADJResultNL<NSNumber *> *)
    extractDoubleNumberWithDictionary:(nullable NSDictionary *)dictionary
    key:(nonnull NSString *)key
{
    if (dictionary == nil) {
        return [ADJResultNL okWithoutValue];
    }

    id _Nullable value = [dictionary objectForKey:key];

    if (value == nil) {
        return [ADJResultNL okWithoutValue];
    }

    if ([value isKindOfClass:[NSNumber class]]) {
        return [ADJResultNL okWithValue:(NSNumber *)value];
    }

    return [ADJResultNL instanceFromNN:^ADJResultNN * _Nonnull(NSString *_Nullable stringValue) {
        return [ADJUtilConv convertToDoubleNumberWithStringValue:stringValue];
    } nlValue:[value description]];
}

+ (nullable NSDictionary *)
extractDictionaryValueWithDictionary:(nullable NSDictionary *)dictionary
key:(nonnull NSString *)key {
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

