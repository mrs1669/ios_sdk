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
#import "ADJBooleanWrapper.h"
#import "ADJUtilJson.h"

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

+ (nullable ADJStringMap *)
    clientStringMapWithKeyValueArray:(nullable NSArray *)keyValueArray
    logger:(nonnull ADJLogger *)logger
    processingFailMessage:(nonnull NSString *)processingFailMessage
    addingFailMessage:(nonnull NSString *)addingFailMessage
    emptyFailMessage:(nonnull NSString *)emptyFailMessage
{
    ADJResult<ADJOptionalFails<ADJStringMap *> *> *_Nonnull parametersResult =
        [ADJUtilConv convertToStringMapWithKeyValueArray:keyValueArray];

    if (parametersResult.value == nil) {
        if (parametersResult.failNonNilInput != nil) {
            [logger errorClient:processingFailMessage resultFail:parametersResult.fail];
        }
        return nil;
    }

    for (ADJResultFail *_Nonnull optionalFail in parametersResult.value.optionalFails) {
        [logger noticeClient:addingFailMessage resultFail:optionalFail];
    }

    if ([parametersResult.value.value isEmpty]) {
        [logger noticeClient:emptyFailMessage];
        return nil;
    }

    return parametersResult.value.value;
}
+ (nonnull ADJResult<ADJOptionalFails<ADJStringMap *> *> *)
    convertToStringMapWithKeyValueArray:(nullable NSArray *)keyValueArray;
{
    if (keyValueArray == nil) {
        return [ADJResult nilInputWithMessage:
                @"Cannot convert to string map with nil key value array"];
    }

    if (keyValueArray.count % 2 != 0) {
        return [ADJResult failWithMessage:
                @"Cannot convert key value array with non-multiple of 2 elements"
                                      key:@"keyValueArray count"
                              stringValue:[ADJUtilF uIntegerFormat:keyValueArray.count]];
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

    return [ADJResult okWithValue:
            [[ADJOptionalFails alloc]
             initWithOptionalFails:optionalFailsMut
             value:[[ADJStringMap alloc] initWithStringMapBuilder:stringMapBuilder]]];
}


+ (nonnull ADJOptionalFails<ADJResult<ADJNonEmptyString *> *> *)
    jsonStringFromNameKeyStringValueArray:
    (nullable NSArray<NSString *> *)nameKeyStringValueArray
{
    return [ADJUtilConv jsonStringFromNameKeyValueArray:nameKeyStringValueArray
                               stringOrElseBooleanValue:YES];
}
+ (nonnull ADJOptionalFails<ADJResult<ADJNonEmptyString *> *> *)
    jsonStringFromNameKeyBooleanValueArray:
    (nullable NSArray<NSString *> *)nameKeyBooleanValueArray
{
    return [ADJUtilConv jsonStringFromNameKeyValueArray:nameKeyBooleanValueArray
                               stringOrElseBooleanValue:NO];
}
+ (nonnull ADJOptionalFails<ADJResult<ADJNonEmptyString *> *> *)
    jsonStringFromNameKeyValueArray:
        (nullable NSArray<NSString *> *)nameKeyValueArray
    stringOrElseBooleanValue:(BOOL)stringOrElseBooleanValue
{
    if (nameKeyValueArray == nil) {
        return [[ADJOptionalFails alloc]
                initWithOptionalFails:nil
                value:[ADJResult nilInputWithMessage:
                       @"Cannot convert to map collection with nil name key value array"]];
    }

    if (nameKeyValueArray.count % 3 != 0) {
        return [[ADJOptionalFails alloc]
                initWithOptionalFails:nil
                value:[ADJResult
                       failWithMessage:
                           @"Cannot convert name key value array with non-multiple of 3 elements"
                       key:@"nameKeyStringValueArray count"
                       stringValue:[ADJUtilF uIntegerFormat:nameKeyValueArray.count]]];
    }

    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut =
        [[NSMutableArray alloc] init];

    NSDictionary<NSString *, NSDictionary<NSString *, id> *> *_Nonnull jsonDictionary =
        [ADJUtilConv jsonDictionaryFromNameKeyValueArray:nameKeyValueArray
                                stringOrElseBooleanValue:stringOrElseBooleanValue
                                        optionalFailsMut:optionalFailsMut];
    if (jsonDictionary.count == 0) {
        return [[ADJOptionalFails alloc]
                initWithOptionalFails:optionalFailsMut
                value:[ADJResult
                       failWithMessage:@"Could not convert any valid entries"]];
    }

    ADJOptionalFails<NSString *> *_Nonnull jsonStringOptFails =
        [ADJUtilJson toStringFromDictionary:jsonDictionary];
    [optionalFailsMut addObjectsFromArray:jsonStringOptFails.optionalFails];

    ADJResult<ADJNonEmptyString *> *_Nonnull jsonStringResult =
        [ADJNonEmptyString instanceFromString:jsonStringOptFails.value];
    if (jsonStringResult.fail != nil) {
        return [[ADJOptionalFails alloc]
                initWithOptionalFails:optionalFailsMut
                value:[ADJResult
                       failWithMessage:@"Could not validate json string"
                       key:@"string fail"
                       otherFail:jsonStringResult.fail]];
    }

    return [[ADJOptionalFails alloc]
            initWithOptionalFails:optionalFailsMut
            value:[ADJResult okWithValue:jsonStringResult.value]];
}
+ (nonnull NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)
    jsonDictionaryFromNameKeyValueArray:(nonnull NSArray<NSObject *> *)nameKeyValueArray
    stringOrElseBooleanValue:(BOOL)stringOrElseBooleanValue
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *_Nonnull
        mapCollectionByNameBuilder =
            [[NSMutableDictionary alloc] initWithCapacity:(nameKeyValueArray.count / 3)];

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
            [ADJUtilConv extractNsNullableStringWithObject:
             [nameKeyValueArray objectAtIndex:i + 1]];
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

        id _Nonnull value = [nameKeyValueArray objectAtIndex:i + 2];

        if ([value isEqual:[NSNull null]]) {
            [optionalFailsMut addObject:
             [[ADJResultFail alloc]
              initWithMessage:@"Cannot add to map collection with null value"
              key:@"nameKeyValueArray index"
              stringValue:[ADJUtilF uIntegerFormat:i + 2]]];
            continue;
        }
        if (stringOrElseBooleanValue) {
            ADJResult<ADJNonEmptyString *> *_Nonnull stringResult =
                [ADJNonEmptyString instanceFromObject:value];
            if (stringResult.fail != nil) {
                ADJResultFailBuilder *_Nonnull resultFailBuilder =
                    [[ADJResultFailBuilder alloc] initWithMessage:
                     @"Cannot add to map collection with invalid string value"];
                [resultFailBuilder withKey:@"string value parsing fail"
                                 otherFail:stringResult.fail];
                [resultFailBuilder withKey:@"nameKeyValueArray index"
                               stringValue:[ADJUtilF uIntegerFormat:i + 2]];
                [optionalFailsMut addObject:[resultFailBuilder build]];
                continue;
            }
        } else {
            ADJResult<ADJBooleanWrapper *> *_Nonnull booleanResult =
                [ADJBooleanWrapper instanceFromObject:value];
            if (booleanResult.fail != nil) {
                ADJResultFailBuilder *_Nonnull resultFailBuilder =
                    [[ADJResultFailBuilder alloc] initWithMessage:
                     @"Cannot add to map collection with invalid boolean value"];
                [resultFailBuilder withKey:@"boolean value parsing fail"
                                 otherFail:booleanResult.fail];
                [resultFailBuilder withKey:@"nameKeyValueArray index"
                               stringValue:[ADJUtilF uIntegerFormat:i + 2]];
                [optionalFailsMut addObject:[resultFailBuilder build]];
                continue;
            }
        }

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

    return mapCollectionByNameBuilder;
}

// assumes [ADJUtilObj copyStringOrNSNullWithInput] was for the string object
+ (nonnull ADJResult<ADJNonEmptyString *> *)extractNsNullableStringWithObject:(nonnull id)object {
    if ([object isEqual:[NSNull null]]) {
        return [ADJResult failWithMessage:@"Cannot create string from NSNull"];
    }

    return [ADJNonEmptyString instanceFromObject:object];
}

@end
