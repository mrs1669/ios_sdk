//
//  ADJUtilConv.m
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJUtilConv.h"

#import "ADJConstants.h"
#import "ADJUtilF.h"

@implementation ADJUtilConv

+ (NSTimeInterval)convertToSecondsWithMilliseconds:(NSUInteger)milliseconds {
    return ((double)milliseconds) / ADJSecondToMilliDouble;
}

+ (nonnull ADJResult<NSNumber *> *)
    convertToIntegerNumberWithStringValue:(nonnull NSString *)stringValue
{
    /* to check: integer formatter rounds possible non integer values, instead of failing
     ADJUtilF *_Nonnull sharedInstance = [self sharedInstance];
     return [sharedInstance.integerFormatter numberFromString:stringValue];
     */
    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:stringValue];
    [scanner setLocale:[ADJUtilF usLocale]];

    NSInteger scannedInteger;
    if (! [scanner scanInteger:&scannedInteger]) {
        return [ADJResult failWithMessage:@"Could not find valid integer representation"
                                      key:@"input string"
                              stringValue:stringValue];
    }

    // Contains INT_MAX or INT_MIN on overflow
    if (scannedInteger == INT_MAX || scannedInteger == INT_MIN) {
        return [ADJResult failWithMessage:@"Found overflow integer value"];
    }

    return [ADJResult okWithValue:[NSNumber numberWithInteger:scannedInteger]];
}

+ (nonnull ADJResult<NSNumber *> *)
    convertToLLNumberWithStringValue:(nonnull NSString *)stringValue
{
    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:stringValue];
    [scanner setLocale:[ADJUtilF usLocale]];

    long long scannedLL;
    if (! [scanner scanLongLong:&scannedLL]) {
        return [ADJResult failWithMessage:@"Could not find valid long long representation"
                                      key:@"input string"
                              stringValue:stringValue];
    }

    // Contains LLONG_MAX or LLONG_MIN on overflow
    if (scannedLL == LLONG_MAX || scannedLL == LLONG_MIN) {
        return [ADJResult failWithMessage:@"Found overflow on long long value"
                                      key:@"input string"
                              stringValue:stringValue];
    }

    return [ADJResult okWithValue:[NSNumber numberWithLongLong:scannedLL]];
}

+ (nonnull ADJResult<NSNumber *> *)
    convertToDoubleNumberWithStringValue:(nonnull NSString *)stringValue
{
    // use number formatter before scanner to smoke out if the value is zero
    //  so that it can't be interpreted as underflow in scan double
    NSNumber *_Nullable formatterDouble =
    [[ADJUtilF decimalStyleFormatter] numberFromString:stringValue];

    if (formatterDouble == nil) {
        return [ADJResult failWithMessage:@"Could not parse double number with formatter"
                                      key:@"string input"
                              stringValue:stringValue];
    }

    if (formatterDouble.doubleValue == 0.0) {
        return [ADJResult okWithValue:formatterDouble];
    }

    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:stringValue];
    [scanner setLocale:[ADJUtilF usLocale]];

    double scannedDBL;

    if (! [scanner scanDouble:&scannedDBL]) {
        return [ADJResult failWithMessage:@"Could not find valid double representation"
                                      key:@"input string"
                              stringValue:stringValue];
    }

    // Contains HUGE_VAL or –HUGE_VAL on overflow, or 0.0 on underflow
    if (scannedDBL == HUGE_VAL || scannedDBL == -( HUGE_VAL ) || scannedDBL == 0.0) {
        return [ADJResult failWithMessage:@"Found overflow double value"
                                      key:@"input string"
                              stringValue:stringValue];
    }

    return [ADJResult okWithValue:[NSNumber numberWithDouble:scannedDBL]];
}

+ (nullable NSString *)convertToBase64StringWithDataValue:(nullable NSData *)dataValue {
    if (dataValue == nil) {
        return nil;
    }

    return [dataValue base64EncodedStringWithOptions:0];
}

+ (nullable NSData *)convertToDataWithBase64String:(nullable NSString *)base64String {
    if (base64String == nil) {
        return nil;
    }

    return [[NSData alloc] initWithBase64EncodedString:base64String
                                               options:0];
}

+ (nonnull ADJResult<NSData *> *)
    convertToJsonDataWithJsonFoundationValue:(nonnull id)jsonFoundationValue
{
    // todo check isValidJSONObject:
    @try {
        NSError *_Nullable errorPtr = nil;
        // If the object will not produce valid JSON then an exception will be thrown
        NSData *_Nullable data =
            [NSJSONSerialization dataWithJSONObject:jsonFoundationValue options:0 error:&errorPtr];

        if (data != nil) {
            return [ADJResult okWithValue:data];
        }
        return [ADJResult failWithMessage:@"NSJSONSerialization dataWithJSONObject without value"
                                    error:errorPtr];
    } @catch (NSException *exception) {
        return [ADJResult failWithMessage:@"NSJSONSerialization dataWithJSONObject exception"
                                exception:exception];
    }
}

+ (nonnull ADJResult<id> *)
    convertToFoundationObjectWithJsonString:(nonnull NSString *)jsonString
{
    return [ADJUtilConv convertToJsonFoundationValueWithJsonData:
             [jsonString dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (nonnull ADJResult<id> *)convertToJsonFoundationValueWithJsonData:(nonnull NSData *)jsonData {
    NSError *_Nullable errorPtr = nil;

    id _Nullable jsonObject =
        [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&errorPtr];

    if (jsonObject != nil) {
        return [ADJResult okWithValue:jsonObject];
    }

    return [ADJResult failWithMessage:@"NSJSONSerialization JSONObjectWithData returned nil"
                                error:errorPtr];
}

+ (nonnull id)convertToFoundationObject:(nonnull id)objectToConvert {
    if ([NSJSONSerialization isValidJSONObject:objectToConvert]) {
        return objectToConvert;
    }

    if ([objectToConvert isKindOfClass:[NSDictionary class]]) {
        NSDictionary *_Nonnull dictionaryToConvert = (NSDictionary *)objectToConvert;
        NSMutableDictionary<NSString *, id> *_Nonnull foundationDictionary =
            [[NSMutableDictionary alloc] initWithCapacity:dictionaryToConvert.count];

        for (id _Nonnull key in dictionaryToConvert) {
            id _Nullable value = dictionaryToConvert[key];
            NSString *_Nonnull keyString = [key description];

            if (value == nil || [value isEqual:[NSNull null]]) {
                [foundationDictionary setObject:[NSNull null] forKey:keyString];
                continue;
            }

            if ([value isKindOfClass:[NSDictionary class]] ||
                [value isKindOfClass:[NSArray class]])
            {
                [foundationDictionary
                 setObject:[ADJUtilConv convertToFoundationObject:value]
                 forKey:keyString];
                continue;
            }

            if ([value isKindOfClass:[NSNumber class]]) {
                [foundationDictionary setObject:value forKey:keyString];
                continue;
            }

            [foundationDictionary setObject:[value description] forKey:keyString];
        }

        return foundationDictionary;
    }

    if ([objectToConvert isKindOfClass:[NSArray class]]) {
        NSArray *_Nonnull arrayToConvert = (NSArray *)objectToConvert;
        NSMutableArray *_Nonnull foundationArray =
            [[NSMutableArray alloc] initWithCapacity:arrayToConvert.count];

        for (id _Nonnull value in arrayToConvert) {
            if ([value isEqual:[NSNull null]]) {
                [foundationArray addObject:[NSNull null]];
                continue;
            }

            if ([value isKindOfClass:[NSDictionary class]] ||
                [value isKindOfClass:[NSArray class]])
            {
                [foundationArray addObject:[ADJUtilConv convertToFoundationObject:value]];
                continue;
            }

            if ([value isKindOfClass:[NSNumber class]]) {
                [foundationArray addObject:value];
                continue;
            }


            [foundationArray addObject:[value description]];
        }

        return foundationArray;
    }

    return [[NSDictionary alloc] init];
}


+ (nonnull ADJOptionalFailsNN<ADJResult<ADJStringMap *> *> *)
    convertToStringMapWithKeyValueArray:(nullable NSArray<NSString *> *)keyValueArray;
{
    if (keyValueArray == nil) {
        return [[ADJOptionalFailsNN alloc]
                initWithOptionalFails:nil
                value:[ADJResult nilInputWithMessage:
                       @"Cannot convert string map with nil key value array"]];
    }

    if (keyValueArray.count % 2 != 0) {
        return [[ADJOptionalFailsNN alloc]
                initWithOptionalFails:nil
                value:[ADJResult
                       failWithMessage:
                           @"Cannot convert key value array with non-multiple of 2 elements"
                       key:@"keyValueArray count"
                       stringValue:[ADJUtilF uIntegerFormat:keyValueArray.count]]];
    }

    ADJStringMapBuilder *_Nonnull stringMapBuilder =
        [[ADJStringMapBuilder alloc] initWithEmptyMap];
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut =
        [[NSMutableArray alloc] init];

    for (NSUInteger i = 0; i < keyValueArray.count; i = i + 2) {
        ADJResult<ADJNonEmptyString *> *_Nonnull keyResult =
            [ADJUtilConv extractNsNullableStringWithObject:[keyValueArray objectAtIndex:i]];

        if (keyResult.fail != nil) {
            ADJResultFailBuilder *_Nonnull resultFailBuilder =
                [[ADJResultFailBuilder alloc] initWithMessage:@"Cannot add to map with key"];
            [resultFailBuilder withKey:@"key parsing fail"
                             otherFail:keyResult.fail];
            [resultFailBuilder withKey:@"keyValueArray index"
                           stringValue:[ADJUtilF uIntegerFormat:i]];
            [optionalFailsMut addObject:[resultFailBuilder build]];
            continue;
        }

        ADJResult<ADJNonEmptyString *> *_Nonnull valueResult =
            [ADJUtilConv extractNsNullableStringWithObject:[keyValueArray objectAtIndex:i + 1]];

        if (valueResult.fail != nil) {
            ADJResultFailBuilder *_Nonnull resultFailBuilder =
                [[ADJResultFailBuilder alloc] initWithMessage:@"Cannot add to map with value"];
            [resultFailBuilder withKey:@"value parsing fail"
                             otherFail:valueResult.fail];
            [resultFailBuilder withKey:@"keyValueArray index"
                           stringValue:[ADJUtilF uIntegerFormat:i + 1]];
            [optionalFailsMut addObject:[resultFailBuilder build]];
            continue;
        }

        ADJNonEmptyString *_Nullable previousValue =
            [stringMapBuilder addPairWithValue:valueResult.value
                                           key:keyResult.value.stringValue];
        if (previousValue != nil) {
            ADJResultFailBuilder *_Nonnull resultFailBuilder =
                [[ADJResultFailBuilder alloc] initWithMessage:
                 @"Previous value of map was overwritten"];
            [resultFailBuilder withKey:@"key"
                           stringValue:keyResult.value.stringValue];
            [resultFailBuilder withKey:@"keyValueArray index"
                           stringValue:[ADJUtilF uIntegerFormat:i]];
            [optionalFailsMut addObject:[resultFailBuilder build]];
        }
    }

    return [[ADJOptionalFailsNN alloc]
            initWithOptionalFails:optionalFailsMut
            value:[ADJResult okWithValue:
                   [[ADJStringMap alloc] initWithStringMapBuilder:stringMapBuilder]]];
}

+ (nonnull ADJOptionalFailsNN<ADJResult<NSDictionary<NSString *, ADJStringKeyDict> *> *> *)
    convertToStringMapCollectionByNameBuilderWithNameKeyValueArray:
        (nullable NSArray<NSString *> *)nameKeyStringValueArray
{
    return [self convertToMapCollectionByNameBuilderWithNameKeyValueArray:nameKeyStringValueArray
                                                            isValueString:YES];
}

+ (nonnull ADJOptionalFailsNN<ADJResult<NSDictionary<NSString *, ADJStringKeyDict> *> *> *)
    convertToNumberBooleanMapCollectionByNameBuilderWithNameKeyValueArray:
        (nullable NSArray *)nameKeyNumberBooleanValueArray
{
    return [self
            convertToMapCollectionByNameBuilderWithNameKeyValueArray:nameKeyNumberBooleanValueArray
            isValueString:NO];
}

+ (nonnull ADJOptionalFailsNN<ADJResult<NSDictionary<NSString *, ADJStringKeyDict> *> *> *)
    convertToMapCollectionByNameBuilderWithNameKeyValueArray:
        (nullable NSArray<NSString *> *)nameKeyValueArray
    isValueString:(BOOL)isValueString
{
    if (nameKeyValueArray == nil) {
        return [[ADJOptionalFailsNN alloc]
                initWithOptionalFails:nil
                value:[ADJResult nilInputWithMessage:
                       @"Cannot convert to map collection with nil name key value array"]];
    }

    if (nameKeyValueArray.count % 3 != 0) {
        return [[ADJOptionalFailsNN alloc]
                initWithOptionalFails:nil
                value:[ADJResult
                       failWithMessage:
                           @"Cannot convert name key value array with non-multiple of 3 elements"
                       key:@"nameKeyStringValueArray count"
                       stringValue:[ADJUtilF uIntegerFormat:nameKeyValueArray.count]]];
    }

    NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *_Nonnull
        mapCollectionByNameBuilder =
            [[NSMutableDictionary alloc] initWithCapacity:(nameKeyValueArray.count / 3)];
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut =
        [[NSMutableArray alloc] init];

    for (NSUInteger i = 0; i < nameKeyValueArray.count; i = i + 3) {
        ADJResult<ADJNonEmptyString *> *_Nonnull nameResult =
            [ADJUtilConv extractNsNullableStringWithObject:[nameKeyValueArray objectAtIndex:i]];
        if (nameResult.fail != nil) {
            ADJResultFailBuilder *_Nonnull resultFailBuilder =
                [[ADJResultFailBuilder alloc] initWithMessage:
                 @"Cannot add to map collection with name"];
            [resultFailBuilder withKey:@"name parsing fail"
                             otherFail:nameResult.fail];
            [resultFailBuilder withKey:@"nameKeyValueArray index"
                           stringValue:[ADJUtilF uIntegerFormat:i]];
            [optionalFailsMut addObject:[resultFailBuilder build]];
            continue;
        }

        ADJResult<ADJNonEmptyString *> *_Nonnull keyResult =
            [ADJUtilConv extractNsNullableStringWithObject:[nameKeyValueArray objectAtIndex:i + 1]];
        if (keyResult.fail != nil) {
            ADJResultFailBuilder *_Nonnull resultFailBuilder =
                [[ADJResultFailBuilder alloc] initWithMessage:
                 @"Cannot add to map collection with key"];
            [resultFailBuilder withKey:@"key parsing fail"
                             otherFail:keyResult.fail];
            [resultFailBuilder withKey:@"nameKeyValueArray index"
                           stringValue:[ADJUtilF uIntegerFormat:i + 1]];
            [optionalFailsMut addObject:[resultFailBuilder build]];
            continue;
        }

        id _Nullable value;
        if (isValueString) {
            ADJResult<ADJNonEmptyString *> *_Nonnull valueResult =
                [ADJUtilConv extractNsNullableStringWithObject:
                 [nameKeyValueArray objectAtIndex:i + 2]];

            if (valueResult.fail != nil) {
                ADJResultFailBuilder *_Nonnull resultFailBuilder =
                    [[ADJResultFailBuilder alloc] initWithMessage:
                     @"Cannot add to map collection with value"];
                [resultFailBuilder withKey:@"value parsing fail"
                                 otherFail:valueResult.fail];
                [resultFailBuilder withKey:@"nameKeyValueArray index"
                               stringValue:[ADJUtilF uIntegerFormat:i + 2]];
                [optionalFailsMut addObject:[resultFailBuilder build]];
            } else {
                value = valueResult.value.stringValue;
            }
        } else {
            value = [nameKeyValueArray objectAtIndex:i + 2];
        }
        if (value == nil) { continue; }

        NSString *_Nonnull name = nameResult.value.stringValue;

        NSMutableDictionary<NSString *, id> *_Nullable mapBuilder =
            [mapCollectionByNameBuilder objectForKey:name];

        if (mapBuilder == nil) {
            mapBuilder = [[NSMutableDictionary alloc] init];
            [mapCollectionByNameBuilder setObject:mapBuilder forKey:name];
        }

        NSString *_Nonnull key = keyResult.value.stringValue;

        NSString *_Nullable previousValue = [mapBuilder objectForKey:key];
        if (previousValue != nil) {
            ADJResultFailBuilder *_Nonnull resultFailBuilder =
                [[ADJResultFailBuilder alloc] initWithMessage:
                 @"Previous value of map collection was overwritten"];
            [resultFailBuilder withKey:@"key"
                           stringValue:keyResult.value.stringValue];
            [resultFailBuilder withKey:@"name"
                           stringValue:nameResult.value.stringValue];
            [resultFailBuilder withKey:@"nameKeyValueArray index"
                           stringValue:[ADJUtilF uIntegerFormat:i]];
            [optionalFailsMut addObject:[resultFailBuilder build]];
        }

        [mapBuilder setObject:value forKey:key];
    }

    return [[ADJOptionalFailsNN alloc]
            initWithOptionalFails:optionalFailsMut
            value:[ADJResult okWithValue: mapCollectionByNameBuilder]];
}

// assumes [ADJUtilObj copyStringOrNSNullWithInput] was for the string object
+ (nonnull ADJResult<ADJNonEmptyString *> *)extractNsNullableStringWithObject:(nonnull id)object {
    if ([object isEqual:[NSNull null]]) {
        return [ADJResult failWithMessage:@"Cannot create string from NSNull"];
    }

    return [ADJNonEmptyString instanceFromObject:object];
}

@end
