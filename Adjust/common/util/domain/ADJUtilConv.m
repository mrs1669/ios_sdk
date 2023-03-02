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

+ (nonnull ADJResultNN<NSNumber *> *)
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
        return [ADJResultNN failWithMessage:
                [NSString stringWithFormat:
                 @"Could not find valid integer representation from string: %@", stringValue]];
    }

    // Contains INT_MAX or INT_MIN on overflow
    if (scannedInteger == INT_MAX || scannedInteger == INT_MIN) {
        return [ADJResultNN failWithMessage:@"Found overflow integer value"];
    }

    return [ADJResultNN okWithValue:@(scannedInteger)];
}

+ (nonnull ADJResultNN<NSNumber *> *)
    convertToLLNumberWithStringValue:(nonnull NSString *)stringValue
{
    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:stringValue];
        [scanner setLocale:[ADJUtilF usLocale]];

    long long scannedLL;
    if (! [scanner scanLongLong:&scannedLL]) {
        return [ADJResultNN failWithMessage:
                [NSString stringWithFormat:
                 @"Could not find valid long long representation from string: %@", stringValue]];
    }

    // Contains LLONG_MAX or LLONG_MIN on overflow
    if (scannedLL == LLONG_MAX || scannedLL == LLONG_MIN) {
        return [ADJResultNN failWithMessage:@"Found overflow long long value"];
    }

    return [ADJResultNN okWithValue:@(scannedLL)];
}

+ (nonnull ADJResultNN<NSNumber *> *)
    convertToDoubleNumberWithStringValue:(nonnull NSString *)stringValue
{
    // use number formatter before scanner to smoke out if the value is zero
    //  so that it can't be interpreted as underflow in scan double
    NSNumber *_Nullable formatterDouble =
    [[ADJUtilF decimalStyleFormatter] numberFromString:stringValue];

    if (formatterDouble == nil) {
        return [ADJResultNN failWithMessage:@"Could not parse double number with formatter"];
    }

    if (formatterDouble.doubleValue == 0.0) {
        return [ADJResultNN okWithValue:formatterDouble];
    }

    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:stringValue];
    [scanner setLocale:[ADJUtilF usLocale]];

    double scannedDBL;

    if (! [scanner scanDouble:&scannedDBL]) {
        return [ADJResultNN failWithMessage:
                [NSString stringWithFormat:
                 @"Could not find valid double representation from string: %@", stringValue]];
    }

    // Contains HUGE_VAL or –HUGE_VAL on overflow, or 0.0 on underflow
    if (scannedDBL == HUGE_VAL || scannedDBL == -( HUGE_VAL ) || scannedDBL == 0.0) {
        return [ADJResultNN failWithMessage:@"Found overflow double value"];
    }

    return [ADJResultNN okWithValue:@(scannedDBL)];
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

+ (nonnull ADJResultNL<NSData *> *)
    convertToJsonDataWithJsonFoundationValue:(nonnull id)jsonFoundationValue
{
    NSError *_Nullable errorPtr = nil;

    // todo check isValidJSONObject:
    NSData *_Nullable data =
        [NSJSONSerialization dataWithJSONObject:jsonFoundationValue options:0 error:&errorPtr];

    if (errorPtr != nil) {
        return [ADJResultNL failWithError:errorPtr
                                  message:@"NSJSONSerialization dataWithJSONObject"];
    } else if (data == nil) {
        return [ADJResultNL okWithoutValue];
    } else {
        return [ADJResultNL okWithValue:data];
    }
}

+ (nonnull ADJResultNL<id> *)
    convertToFoundationObjectWithJsonString:(nonnull NSString *)jsonString
{
    return [ADJUtilConv convertToJsonFoundationValueWithJsonData:
             [jsonString dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (nonnull ADJResultNL<id> *)convertToJsonFoundationValueWithJsonData:(nonnull NSData *)jsonData {
    NSError *_Nullable errorPtr = nil;

    id _Nullable jsonObject =
        [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&errorPtr];

    if (errorPtr != nil) {
        return [ADJResultNL failWithError:errorPtr
                                  message:@"NSJSONSerialization JSONObjectWithData"];
    } else if (jsonObject == nil) {
        return [ADJResultNL okWithoutValue];
    } else {
        return [ADJResultNL okWithValue:jsonObject];
    }
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

+ (nullable ADJStringMap *)
    convertToStringMapWithKeyValueArray:(nullable NSArray *)keyValueArray
    sourceDescription:(nonnull NSString *)sourceDescription
    logger:(nonnull ADJLogger *)logger
{
    if (keyValueArray == nil) {
        return nil;
    }

    if (keyValueArray.count % 2 != 0) {
        [logger debugDev:
         @"Cannot convert key value array with non-multiple of 2 elements"
                     key:@"keyValueArray count"
                   value:[ADJUtilF uIntegerFormat:keyValueArray.count].description
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    ADJStringMapBuilder *_Nonnull stringMapBuilder =
    [[ADJStringMapBuilder alloc] initWithEmptyMap];

    for (NSUInteger i = 0; i < keyValueArray.count; i = i + 2) {
        ADJResultNN<ADJNonEmptyString *> *_Nonnull keyResult =
            [ADJUtilConv extractNsNullableStringWithObject:[keyValueArray objectAtIndex:i]];

        if (keyResult.fail != nil) {
            [logger debugDev:@"Cannot add to map with key"
                         key:ADJLogFromKey
                       value:sourceDescription
                  resultFail:keyResult.fail
                   issueType:ADJIssueInvalidInput];
            continue;
        }

        ADJResultNN<ADJNonEmptyString *> *_Nonnull valueResult =
            [ADJUtilConv extractNsNullableStringWithObject:[keyValueArray objectAtIndex:i + 1]];

        if (valueResult.fail != nil) {
            [logger debugDev:@"Cannot add to map with value"
                         key:ADJLogFromKey
                       value:sourceDescription
                  resultFail:valueResult.fail
                   issueType:ADJIssueInvalidInput];
            continue;
        }

        ADJNonEmptyString *_Nullable previousValue =
            [stringMapBuilder addPairWithValue:valueResult.value
                                           key:keyResult.value.stringValue];
        if (previousValue != nil) {
            [logger debugDev:@"Previous value was overwritten"
                        from:sourceDescription
                         key:@"key"
                       value:keyResult.value.stringValue];
        }
    }

    if (stringMapBuilder.countPairs == 0) {
        return nil;
    }

    return [[ADJStringMap alloc] initWithStringMapBuilder:stringMapBuilder];
}

+ (nullable NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *)
    convertToStringMapCollectionByNameBuilderWithNameKeyValueArray:
        (nullable NSArray<NSString *> *)nameKeyStringValueArray
    sourceDescription:(nonnull NSString *)sourceDescription
    logger:(nonnull ADJLogger *)logger
{
    return [self convertToMapCollectionByNameBuilderWithNameKeyValueArray:nameKeyStringValueArray
                                                        sourceDescription:sourceDescription
                                                                   logger:logger
                                                            isValueString:YES];
}

+ (nullable NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *)
    convertToNumberBooleanMapCollectionByNameBuilderWithNameKeyValueArray:
        (nullable NSArray *)nameKeyNumberBooleanValueArray
    sourceDescription:(nonnull NSString *)sourceDescription
    logger:(nonnull ADJLogger *)logger
{
    return [self
            convertToMapCollectionByNameBuilderWithNameKeyValueArray:nameKeyNumberBooleanValueArray
            sourceDescription:sourceDescription
            logger:logger
            isValueString:NO];
}

+ (nullable NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *)
    convertToMapCollectionByNameBuilderWithNameKeyValueArray:
        (nullable NSArray<NSString *> *)nameKeyValueArray
    sourceDescription:(nonnull NSString *)sourceDescription
    logger:(nonnull ADJLogger *)logger
    isValueString:(BOOL)isValueString
{
    if (nameKeyValueArray == nil) {
        return nil;
    }

    if (nameKeyValueArray.count % 3 != 0) {
        [logger debugDev:
         @"Cannot convert name key value array with non-multiple of 3 elements"
                     key:@"nameKeyStringValueArray count"
                   value:[ADJUtilF uIntegerFormat:nameKeyValueArray.count].description
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *_Nonnull
    mapCollectionByNameBuilder =
        [[NSMutableDictionary alloc] initWithCapacity:(nameKeyValueArray.count / 3)];

    for (NSUInteger i = 0; i < nameKeyValueArray.count; i = i + 3) {
        ADJResultNN<ADJNonEmptyString *> *_Nonnull nameResult =
            [ADJUtilConv extractNsNullableStringWithObject:[nameKeyValueArray objectAtIndex:i]];

        if (nameResult.fail != nil) {
            [logger debugDev:@"Cannot add to map collection with name"
                         key:ADJLogFromKey
                       value:sourceDescription
                  resultFail:nameResult.fail
                   issueType:ADJIssueInvalidInput];
            continue;
        }

        ADJResultNN<ADJNonEmptyString *> *_Nonnull keyResult =
            [ADJUtilConv extractNsNullableStringWithObject:[nameKeyValueArray objectAtIndex:i + 1]];

        if (keyResult.fail != nil) {
            [logger debugDev:@"Cannot add to map collection with key"
                         key:ADJLogFromKey
                       value:sourceDescription
                  resultFail:keyResult.fail
                   issueType:ADJIssueInvalidInput];
            continue;
        }

        id _Nullable value;
        if (isValueString) {
            ADJResultNN<ADJNonEmptyString *> *_Nonnull valueResult =
                [ADJUtilConv extractNsNullableStringWithObject:
                 [nameKeyValueArray objectAtIndex:i + 2]];

            if (valueResult.fail != nil) {
                [logger debugDev:@"Cannot add to map collection with string value"
                             key:ADJLogFromKey
                           value:sourceDescription
                      resultFail:valueResult.fail
                       issueType:ADJIssueInvalidInput];
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
            [logger debugDev:@"Value was overwritten"
                        from:sourceDescription
                         key:@"key"
                       value:key];
        }

        [mapBuilder setObject:value forKey:key];
    }

    if (mapCollectionByNameBuilder.count == 0) {
        return nil;
    }

    return mapCollectionByNameBuilder;
}

// assumes [ADJUtilObj copyStringOrNSNullWithInput] was for the string object
+ (nonnull ADJResultNN<ADJNonEmptyString *> *)extractNsNullableStringWithObject:(nonnull id)object {
    if ([object isEqual:[NSNull null]]) {
        return [ADJResultNN failWithMessage:@"Cannot create string from NSNull"];
    }

    return [ADJNonEmptyString instanceFromObject:object];
}

@end
