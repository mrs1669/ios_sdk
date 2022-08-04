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

+ (nullable NSNumber *)convertToIntegerNumberWithStringValue:(nullable NSString *)stringValue {
    if (stringValue == nil) {
        return nil;
    }
    /* to check: integer formatter rounds possible non integer values, instead of failing
    ADJUtilF *_Nonnull sharedInstance = [self sharedInstance];
    return [sharedInstance.integerFormatter numberFromString:stringValue];
    */
    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:stringValue];
    [scanner setLocale:[ADJUtilF usLocale]];
    NSInteger scannedInteger;
    if (! [scanner scanInteger:&scannedInteger]) {
        return nil;
    }

    // Contains INT_MAX or INT_MIN on overflow
    if (scannedInteger == INT_MAX || scannedInteger == INT_MIN) {
        return nil;
    }

    return @(scannedInteger);
}
+ (nullable NSNumber *)convertToLLNumberWithStringValue:(nullable NSString *)stringValue {
    if (stringValue == nil) {
        return nil;
    }

    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:stringValue];
    [scanner setLocale:[ADJUtilF usLocale]];
    long long scannedLL;
    if (! [scanner scanLongLong:&scannedLL]) {
        return nil;
    }

    // Contains LLONG_MAX or LLONG_MIN on overflow
    if (scannedLL == LLONG_MAX || scannedLL == LLONG_MIN) {
        return nil;
    }

    return @(scannedLL);
}
+ (nullable NSNumber *)convertToDoubleNumberWithStringValue:(nonnull NSString *)stringValue {
    if (stringValue == nil) {
        return nil;
    }

    // use number formatter before scanner to smoke out if the value is zero
    //  so that it can't be interpreted as underflow in scan double
    NSNumber *_Nullable formatterDouble =
        [[ADJUtilF decimalStyleFormatter] numberFromString:stringValue];

    if (formatterDouble == nil) {
        return nil;
    }

    if (formatterDouble.doubleValue == 0.0) {
        return formatterDouble;
    }

    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:stringValue];
    [scanner setLocale:[ADJUtilF usLocale]];

    double scannedDBL;

    if (! [scanner scanDouble:&scannedDBL]) {
        return nil;
    }

    // Contains HUGE_VAL or –HUGE_VAL on overflow, or 0.0 on underflow
    if (scannedDBL == HUGE_VAL || scannedDBL == -( HUGE_VAL ) || scannedDBL == 0.0) {
        return nil;
    }

    return @(scannedDBL);
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

+ (nullable NSData *)
    convertToJsonDataWithJsonFoundationValue:(nonnull id)jsonFoundationValue
    errorPtr:(NSError * _Nullable * _Nonnull)errorPtr
{
    return [NSJSONSerialization dataWithJSONObject:jsonFoundationValue options:0 error:errorPtr];
}
+ (nullable id)
    convertToJsonFoundationValueWithJsonData :(nonnull NSData *)jsonData
    errorPtr:(NSError * _Nullable * _Nonnull)errorPtr
{
    return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:errorPtr];
}

+ (nullable ADJStringMap *)
    convertToStringMapWithKeyValueArray:
        (nullable NSArray *)keyValueArray
    sourceDescription:(nonnull NSString *)sourceDescription
    logger:(nonnull ADJLogger *)logger
{
    if (keyValueArray == nil) {
        return nil;
    }

    if (keyValueArray.count % 2 != 0) {
        [logger error:@"Cannot convert %@ key value array with non-multiple of elements",
            [ADJUtilF uIntegerFormat:keyValueArray.count]];
        return nil;
    }

    ADJStringMapBuilder *_Nonnull stringMapBuilder =
        [[ADJStringMapBuilder alloc] initWithEmptyMap];

    for (NSUInteger i = 0; i < keyValueArray.count; i = i + 2) {
        id _Nonnull keyObject = [keyValueArray objectAtIndex:i];
        if ([keyObject isEqual:[NSNull null]]) {
            [logger error:@"Cannot add key/value to %@ with invalid key", sourceDescription];
            continue;
        }

        ADJNonEmptyString *_Nullable key =
            [ADJNonEmptyString instanceFromString:(NSString *)keyObject
                                 sourceDescription:sourceDescription
                                            logger:logger];
        if (key == nil) {
            [logger error:@"Cannot add key/value to %@ with invalid key", sourceDescription];
            continue;
        }

        id _Nonnull valueObject = [keyValueArray objectAtIndex:(i + 1)];
        if ([valueObject isEqual:[NSNull null]]) {
            [logger error:@"Cannot add key/value to %@ with invalid value", sourceDescription];
            continue;
        }

        ADJNonEmptyString *_Nullable value =
            [ADJNonEmptyString instanceFromString:(NSString *)valueObject
                                 sourceDescription:sourceDescription
                                            logger:logger];
        if (value == nil) {
            [logger error:@"Cannot add key/value to %@ with invalid value", sourceDescription];
            continue;
        }

        ADJNonEmptyString *_Nullable previousValue =
            [stringMapBuilder addPairWithValue:value
                             key:key.stringValue];
        if (previousValue != nil) {
            [logger info:@"Value of key %@ of %@ was overwritten",
                key, sourceDescription];
        }
    }

    if (stringMapBuilder.countPairs == 0) {
        return nil;
    }

    return [[ADJStringMap alloc] initWithStringMapBuilder:stringMapBuilder];
}
+ (nullable NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSString *> *> *)
    convertToMapCollectionByNameBuilderWithKeyValueArray:
        (nullable NSArray<NSString *> *)keyValueArray
    sourceDescription:(nonnull NSString *)sourceDescription
    logger:(nonnull ADJLogger *)logger
{
    if (keyValueArray == nil) {
        return nil;
    }

    if (keyValueArray.count % 3 != 0) {
        [logger error:@"Cannot convert %@ key value array with non-multiple of elements",
            [ADJUtilF uIntegerFormat:keyValueArray.count]];
        return nil;
    }

    NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSString *> *> *_Nonnull
        mapCollectionByNameBuilder =
            [[NSMutableDictionary alloc] initWithCapacity:(keyValueArray.count / 3)];

    for (NSUInteger i = 0; i < keyValueArray.count; i = i + 3) {
        id _Nonnull nameObject = [keyValueArray objectAtIndex:i];
        if ([nameObject isEqual:[NSNull null]]) {
            [logger error:@"Cannot add map name to %@ with invalid name", sourceDescription];
            continue;
        }

        ADJNonEmptyString *_Nullable name =
            [ADJNonEmptyString instanceFromString:(NSString *)nameObject
                                 sourceDescription:sourceDescription
                                            logger:logger];
        if (name == nil) {
            [logger error:@"Cannot add map name to %@ with invalid name", sourceDescription];
            continue;
        }

        id _Nonnull keyObject = [keyValueArray objectAtIndex:(i + 1)];
        if ([keyObject isEqual:[NSNull null]]) {
            [logger error:@"Cannot add key/value to %@ with invalid key", sourceDescription];
            continue;
        }

        ADJNonEmptyString *_Nullable key =
            [ADJNonEmptyString instanceFromString:(NSString *)keyObject
                                 sourceDescription:sourceDescription
                                            logger:logger];
        if (key == nil) {
            [logger error:@"Cannot add key/value to %@ with invalid key", sourceDescription];
            continue;
        }

        id _Nonnull valueObject = [keyValueArray objectAtIndex:(i + 2)];
        if ([valueObject isEqual:[NSNull null]]) {
            [logger error:@"Cannot add key/value to %@ with invalid value", sourceDescription];
            continue;
        }

        ADJNonEmptyString *_Nullable value =
            [ADJNonEmptyString instanceFromString:(NSString *)valueObject
                                 sourceDescription:sourceDescription
                                            logger:logger];
        if (value == nil) {
            [logger error:@"Cannot add key/value to %@ with invalid value", sourceDescription];
            continue;
        }

        NSMutableDictionary<NSString *, NSString *> *_Nullable mapBuilder =
            [mapCollectionByNameBuilder objectForKey:name.stringValue];

        if (mapBuilder == nil) {
            mapBuilder = [[NSMutableDictionary alloc] init];
            [mapCollectionByNameBuilder setObject:mapBuilder
                                           forKey:name.stringValue];
        }

        NSString *_Nullable previousValue = [mapBuilder objectForKey:key.stringValue];
        if (previousValue != nil) {
            [logger info:@"Value of key %@ of %@ was overwritten",
                key, sourceDescription];
        }

        [mapBuilder setObject:value.stringValue
                       forKey:key.stringValue];
    }

    if (mapCollectionByNameBuilder.count == 0) {
        return nil;
    }

    return mapCollectionByNameBuilder;
}

@end