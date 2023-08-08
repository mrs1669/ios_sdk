//
//  ADJUtilJson.m
//  Adjust
//
//  Created by Pedro Silva on 11.04.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJUtilJson.h"
#import "ADJConstants.h"

@implementation ADJUtilJson

+ (nonnull ADJResult<NSDictionary<NSString *, id> *> *)
    toDictionaryFromData:(nonnull NSData *)jsonData
{
    NSError *_Nullable errorPtr = nil;

    id _Nullable jsonObject =
        [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&errorPtr];

    if (jsonObject == nil) {
        return [ADJResult failWithMessage:@"NSJSONSerialization JSONObjectWithData returned nil"
                                    error:errorPtr];
    }

    if (! [jsonObject isKindOfClass:[NSDictionary class]]) {
        return [ADJResult failWithMessage:@"Converted Json object is not a dictionary"
                                        key:ADJLogActualKey
                                stringValue:NSStringFromClass([jsonObject class])];
    }

    return [ADJResult okWithValue:jsonObject];
}

+ (nonnull ADJResult<NSString *> *)toStringFromData:(nonnull NSData *)jsonData {
    NSString *_Nullable converted =
        [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    if (converted == nil) {
        return [ADJResult failWithMessage:@"Could not json NSString from initWithData"];
    }

    return [ADJResult okWithValue:converted];
}

+ (nonnull ADJOptionalFails<NSString *> *)toStringFromDictionary:
    (nonnull NSDictionary<NSString *, id> *)jsonDictionary
{
    ADJResult<NSString *> *_Nonnull jsonStringResult =
        [ADJUtilJson toStringThroughNSJSONSerializationWithObject:jsonDictionary];
    if (jsonStringResult.fail == nil) {
        return [[ADJOptionalFails alloc] initWithOptionalFails:nil
                                                           value:jsonStringResult.value];
    }

    NSMutableArray<ADJResultFail *> *optionalFailsMut =
        [[NSMutableArray alloc] initWithObjects:jsonStringResult.fail, nil];

    return [[ADJOptionalFails alloc]
            initWithOptionalFails:optionalFailsMut
            value:[ADJUtilJson toStringManuallyWithDictionary:jsonDictionary
                                             optionalFailsMut:optionalFailsMut]];
}
+ (nonnull ADJOptionalFails<NSString *> *)toStringFromArray:(nonnull NSArray<id> *)jsonArray {
    ADJResult<NSString *> *_Nonnull jsonStringResult =
        [ADJUtilJson toStringThroughNSJSONSerializationWithObject:jsonArray];
    if (jsonStringResult.fail == nil) {
        return [[ADJOptionalFails alloc] initWithOptionalFails:nil
                                                           value:jsonStringResult.value];
    }

    NSMutableArray<ADJResultFail *> *optionalFailsMut =
        [[NSMutableArray alloc] initWithObjects:jsonStringResult.fail, nil];

    return [[ADJOptionalFails alloc]
            initWithOptionalFails:optionalFailsMut
            value:[ADJUtilJson toStringManuallyWithArray:jsonArray
                                             optionalFailsMut:optionalFailsMut]];
}

+ (nonnull ADJResult<NSString *> *)toStringThroughNSJSONSerializationWithObject:
    (nonnull id)jsonObject
{
    ADJResult<NSData *> *_Nonnull jsonDataResult = [ADJUtilJson toDataFromObject:jsonObject];
    if (jsonDataResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Cannot convert json object to data using NSJSONSerialization"
                                      key:@"data convertion fail"
                                otherFail:jsonDataResult.fail];
    }

    ADJResult<NSString *> *_Nonnull jsonStringResult =
        [ADJUtilJson toStringFromData:jsonDataResult.value];
    if (jsonStringResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Cannot convert json data to string using NSJSONSerialization"
                                      key:@"string convertion fail"
                                otherFail:jsonStringResult.fail];
    }

    return jsonStringResult;
}
+ (nonnull NSString *)
    toStringManuallyWithDictionary:
        (nonnull NSDictionary *)dictionary
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    NSMutableString *_Nonnull jsonStringBuilder =  [[NSMutableString alloc] initWithString:@"{"];

    NSString *_Nonnull pairSeparator = @"";

    for (id _Nonnull key in dictionary) {
        if (! [key isKindOfClass:[NSString class]]) {
            ADJResultFailBuilder *_Nonnull failBuilder =
                [[ADJResultFailBuilder alloc]
                 initWithMessage:@"Could not add pair into json dictionary with non-string key"];
            [failBuilder withKey:ADJLogActualKey
                     stringValue:NSStringFromClass([key class])];
            [failBuilder withKey:@"key description"
                     stringValue:[key description]];
            [optionalFailsMut addObject:[failBuilder build]];
            continue;
        }

        id _Nonnull value = [dictionary objectForKey:key];
        NSString *_Nullable stringValue = nil;

        // small optimization to avoid extra call in the most common case, string value
        // TODO: parse string correctly following RFC 4627
        if ([value isKindOfClass:[NSString class]]) {
            stringValue = [NSString stringWithFormat:@"\"%@\"", value];
        } else {
            stringValue = [ADJUtilJson toStringManuallyWithNonStringJsonValue:value
                                                             optionalFailsMut:optionalFailsMut];
        }
        if (stringValue == nil) {
            ADJResultFailBuilder *_Nonnull failBuilder =
                [[ADJResultFailBuilder alloc]
                 initWithMessage:@"Could not add pair into json dictionary with invalid value"];
            [failBuilder withKey:@"value description"
                     stringValue:[value description]];
            [failBuilder withKey:@"key in pair"
                     stringValue:key];
            [optionalFailsMut addObject:[failBuilder build]];
            continue;
        }
        // appends separator only after first iteration
        [jsonStringBuilder appendString:pairSeparator];
        pairSeparator = @", ";

        [jsonStringBuilder appendFormat:@"\"%@\": %@", key, stringValue];
    }

    [jsonStringBuilder appendString:@"}"];
    return jsonStringBuilder;
}
+ (nonnull NSString *)
    toStringManuallyWithArray:
        (nonnull NSArray *)array
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    NSMutableString *_Nonnull jsonStringBuilder =  [[NSMutableString alloc] initWithString:@"["];

    NSString *_Nonnull pairSeparator = @"";

    for (id _Nonnull value in array) {
        NSString *_Nullable stringValue = nil;

        // small optimization to avoid extra call in the most common case, string value
        if ([value isKindOfClass:[NSString class]]) {
            stringValue = [NSString stringWithFormat:@"\"%@\"", value];
        } else {
            stringValue = [ADJUtilJson toStringManuallyWithNonStringJsonValue:value
                                                             optionalFailsMut:optionalFailsMut];
        }

        if (stringValue == nil) {
            [optionalFailsMut addObject:
             [[ADJResultFail alloc]
              initWithMessage:@"Could not add value into json array with invalid value"
              key:@"value description"
              stringValue:[value description]]];
            continue;
        }

        // appends separator only after first iteration
        [jsonStringBuilder appendString:pairSeparator];
        pairSeparator = @", ";

        [jsonStringBuilder appendFormat:@"%@", stringValue];
    }

    [jsonStringBuilder appendString:@"]"];
    return jsonStringBuilder;
}
+ (nullable NSString *)
    toStringManuallyWithNonStringJsonValue:(nonnull id)jsonValue
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    if ([jsonValue isKindOfClass:[NSDictionary class]]) {
        return [ADJUtilJson toStringManuallyWithDictionary:jsonValue
                                          optionalFailsMut:optionalFailsMut];
    }
    if ([jsonValue isKindOfClass:[NSArray class]]) {
        return [ADJUtilJson toStringManuallyWithArray:jsonValue
                                     optionalFailsMut:optionalFailsMut];
    }
    if ([jsonValue isKindOfClass:[NSNull class]]) {
        return @"null";
    }
    if ([jsonValue isKindOfClass:[NSNumber class]]) {
        if ((__bridge CFBooleanRef)jsonValue == kCFBooleanTrue) {
            return @"true";
        }
        if((__bridge CFBooleanRef)jsonValue == kCFBooleanFalse) {
            return @"false";
        }
        return [(NSNumber *)jsonValue stringValue];
    }

    [optionalFailsMut addObject:
     [[ADJResultFail alloc] initWithMessage:@"Unexpected invalid json type value"
                                        key:ADJLogActualKey
                                stringValue:NSStringFromClass([jsonValue class])]];

    return nil;
}
+ (nonnull ADJResult<NSData *> *)toDataFromObject:(nonnull id)jsonObject {
    @try {
        NSError *_Nullable errorPtr = nil;
        // If the object will not produce valid JSON then an exception will be thrown
        NSData *_Nullable data =
            [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&errorPtr];

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

+ (nonnull ADJResult<NSDictionary<NSString *, id> *> *)
    toDictionaryFromString:(nonnull NSString *)jsonString
{
    NSData *_Nullable data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil) {
        return [ADJResult failWithMessage:
                @"json string dataUsingEncoding:NSUTF8StringEncoding returned nil"];
    }

    return [ADJUtilJson toDictionaryFromData:data];
}

+ (nonnull ADJOptionalFails<NSDictionary<NSString *, id> *> *)
    toJsonDictionary:(nonnull NSDictionary *)dictionary
{
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        return [[ADJOptionalFails alloc] initWithOptionalFails:nil
                                                           value:dictionary];
    }

    NSMutableArray<ADJResultFail *> *optionalFailsMut =
        [[NSMutableArray alloc] initWithObjects:
         [[ADJResultFail alloc] initWithMessage:@"Dictionary is not valid Json to start with"]
         , nil];

    return [[ADJOptionalFails alloc]
            initWithOptionalFails:optionalFailsMut
            value:[ADJUtilJson toJsonDictionaryWithDictionary:dictionary
                                             optionalFailsMut:optionalFailsMut]];
}
+ (nonnull NSDictionary<NSString *, id> *)
    toJsonDictionaryWithDictionary:(nonnull NSDictionary *)dictionary
    optionalFailsMut:(nullable NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    NSMutableDictionary<NSString *, id> *_Nonnull jsonDictionaryMut =
        [[NSMutableDictionary alloc] initWithCapacity:dictionary.count];

    for (id _Nonnull key in dictionary) {
        if (! [key isKindOfClass:[NSString class]]) {
            ADJResultFailBuilder *_Nonnull failBuilder =
            [[ADJResultFailBuilder alloc] initWithMessage:
             @"Unexpected non-string class key for dictionary"];
            [failBuilder withKey:ADJLogActualKey
                     stringValue:NSStringFromClass([key class])];
            [failBuilder withKey:@"key description"
                     stringValue:[key description]];
            [optionalFailsMut addObject:[failBuilder build]];
        }
        NSString *_Nonnull keyString = [key description];

        id _Nonnull value = dictionary[key];

        if ([value isKindOfClass:[NSString class]]
            || [value isKindOfClass:[NSNumber class]]
            || [value isKindOfClass:[NSNull class]])
        {
            [jsonDictionaryMut setObject:value forKey:keyString];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            [jsonDictionaryMut
             setObject:[ADJUtilJson toJsonDictionaryWithDictionary:value
                                                  optionalFailsMut:optionalFailsMut]
             forKey:keyString];;
        } else if ([value isKindOfClass:[NSArray class]]) {
            [jsonDictionaryMut
             setObject:[ADJUtilJson toJsonArrayWithArray:value
                                        optionalFailsMut:optionalFailsMut]
             forKey:keyString];
        } else {
            ADJResultFailBuilder *_Nonnull failBuilder =
                [[ADJResultFailBuilder alloc] initWithMessage:
                 @"Unexpected invalid json type for dictionary value"];
            [failBuilder withKey:ADJLogActualKey
                     stringValue:NSStringFromClass([value class])];
            [failBuilder withKey:@"value description"
                     stringValue:[value description]];
            [optionalFailsMut addObject:[failBuilder build]];

            [jsonDictionaryMut setObject:[value description] forKey:keyString];
        }
    }

    return jsonDictionaryMut;
}
+ (nonnull NSArray<id> *)
    toJsonArrayWithArray:(nonnull NSArray<id> *)array
    optionalFailsMut:(nullable NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    NSMutableArray<id> *_Nonnull jsonArrayMut = [[NSMutableArray alloc] init];

    for (id _Nonnull value in array) {
        if ([value isKindOfClass:[NSString class]]
            || [value isKindOfClass:[NSNumber class]]
            || [value isKindOfClass:[NSNull class]])
        {
            [jsonArrayMut addObject:value];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            [jsonArrayMut addObject:[ADJUtilJson toJsonDictionaryWithDictionary:value
                                                               optionalFailsMut:optionalFailsMut]];
        } else if ([value isKindOfClass:[NSArray class]]) {
            [jsonArrayMut addObject:[ADJUtilJson toJsonArrayWithArray:value
                                                     optionalFailsMut:optionalFailsMut]];
        } else {
            ADJResultFailBuilder *_Nonnull failBuilder =
                [[ADJResultFailBuilder alloc] initWithMessage:
                 @"Unexpected invalid json type for array element"];
            [failBuilder withKey:ADJLogActualKey
                     stringValue:NSStringFromClass([value class])];
            [failBuilder withKey:@"element description"
                     stringValue:[value description]];
            [optionalFailsMut addObject:[failBuilder build]];

            [jsonArrayMut addObject:[value description]];
        }
    }

    return jsonArrayMut;
}

@end
