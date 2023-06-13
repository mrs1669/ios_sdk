//
//  ADJStringMap.m
//  Adjust
//
//  Created by Aditi Agrawal on 18/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJStringMap.h"

#import "ADJConstants.h"
#import "ADJUtilF.h"
#import "ADJUtilObj.h"
#import "ADJUtilConv.h"
#import "ADJUtilJson.h"

//#import "ADJResultFail.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readwrite, strong, nonatomic)
     NSDictionary<NSString *, ADJNonEmptyString *> *map;
*/
@interface ADJStringMap ()

#pragma mark - Internal variables
@property (nullable, readwrite, strong, nonatomic)
    NSDictionary<NSString *, NSString *> *cachedJsonStringDictionary;
@property (nullable, readwrite, strong, nonatomic) ADJNonEmptyString *cachedJsonString;

@end

@implementation ADJStringMap
#pragma mark Instantiation
- (nonnull instancetype)initWithStringMapBuilder:(nonnull ADJStringMapBuilder *)stringMapBuilder {
    return [self initWithMap:[stringMapBuilder mapCast]
  cachedJsonStringDictionary:nil
            cachedJsonString:nil];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (nonnull ADJResult<ADJStringMap *> *)
    instanceFromIoValue:(nullable ADJNonEmptyString *)ioValue
{
    if (ioValue == nil) {
        return [ADJResult nilInputWithMessage:@"Cannot create string map from nil IoValue"];
    }

    ADJResult<NSDictionary<NSString *, id> *> *_Nonnull jsonDictionaryResult =
        [ADJUtilJson toDictionaryFromString:ioValue.stringValue];

    if (jsonDictionaryResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Cannot convert from json string IoValue to json dictionary for string map"
                                        key:@"json dictionary fail"
                                  otherFail:jsonDictionaryResult.fail];
    }

    NSMutableDictionary<NSString *, ADJNonEmptyString *> *_Nonnull map =
        [NSMutableDictionary dictionaryWithCapacity:jsonDictionaryResult.value.count];
    for (NSString *_Nonnull keyString in jsonDictionaryResult.value) {
        ADJResult<ADJNonEmptyString *> *_Nonnull keyResult =
            [ADJNonEmptyString instanceFromString:keyString];
        if (keyResult.fail != nil) {
            return [ADJResult failWithMessage:@"Cannot create string map instance from IoValue"
                                          key:@"key convertion fail"
                                    otherFail:keyResult.fail];
        }

        id _Nullable valueObject =
            [jsonDictionaryResult.value objectForKey:keyResult.value.stringValue];
        ADJResult<ADJNonEmptyString *> *_Nonnull valueResult =
            [ADJNonEmptyString instanceFromObject:valueObject];
        if (valueResult.fail != nil) {
            return [ADJResult failWithMessage:@"Cannot create string map instance from IoValue"
                                          key:@"value convertion fail"
                                    otherFail:valueResult.fail];
        }

        [map setObject:valueResult.value forKey:keyResult.value.stringValue];
    }

    return [ADJResult okWithValue:[[ADJStringMap alloc] initWithMap:map
                                         cachedJsonStringDictionary:jsonDictionaryResult.value
                                                   cachedJsonString:ioValue]];
}

#pragma mark - Private constructors
- (nonnull instancetype)
    initWithMap:(nonnull NSDictionary<NSString *, ADJNonEmptyString*> *)map
    cachedJsonStringDictionary:
        (nullable NSDictionary<NSString *, NSString *> *)cachedJsonStringDictionary
    cachedJsonString:(nullable ADJNonEmptyString *)cachedJsonString
{
    self = [super init];
    
    _map = map;
    _cachedJsonStringDictionary = cachedJsonStringDictionary;
    _cachedJsonString = cachedJsonString;

    return self;
}

#pragma mark Public API
- (nullable ADJNonEmptyString *)pairValueWithKey:(nonnull NSString *)key {
    return [self.map objectForKey:key];
}

- (NSUInteger)countPairs {
    return self.map.count;
}

- (BOOL)isEmpty {
    return self.map.count == 0;
}

- (nonnull NSDictionary<NSString *, NSString *> *)jsonStringDictionary {
    if (self.cachedJsonStringDictionary != nil) {
        return self.cachedJsonStringDictionary;
    }

    self.cachedJsonStringDictionary = [self convertToJsonStringDictionary];

    return self.cachedJsonStringDictionary;
}

#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    return [self jsonString];
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    return [self jsonString];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:@""
                                 stringKeyDictionary:self.map];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    
    hashCode = ADJHashCodeMultiplier * hashCode + [self.map hash];
    
    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[ADJStringMap class]]) {
        return NO;
    }
    
    ADJStringMap *other = (ADJStringMap *)object;
    return [ADJUtilObj objectEquals:self.map other:other.map];
}

#pragma mark Internal Methods
- (nonnull ADJNonEmptyString *)jsonString {
    if (self.cachedJsonString != nil) {
        return self.cachedJsonString;
    }

    ADJOptionalFails<NSString *> *_Nonnull jsonStringOptFails =
        [ADJUtilJson toStringFromDictionary:[self jsonStringDictionary]];

    // optional fails are ignored, since we don't have logger when this is requsted
    ADJResult<ADJNonEmptyString *> *_Nonnull jsonStringResult =
        [ADJNonEmptyString instanceFromString:jsonStringOptFails.value];

    if (jsonStringResult.fail != nil) {
        // fail is being ignored, since there is no logger to use it
        //  could be refac to cache the result and inject it to the local thread storage
        self.cachedJsonString = [[ADJNonEmptyString alloc] initWithConstStringValue:@"{}"];
    } else {
        self.cachedJsonString = jsonStringResult.value;
    }

    return self.cachedJsonString;
}

- (nonnull NSDictionary<NSString *, NSString *> *)convertToJsonStringDictionary {
    NSMutableDictionary<NSString *, NSString *> *_Nonnull jsonStringDictionary =
    [NSMutableDictionary dictionaryWithCapacity:self.map.count];
    
    for (NSString *_Nonnull key in self.map) {
        ADJNonEmptyString *_Nonnull value = [self.map objectForKey:key];
        [jsonStringDictionary setObject:value.stringValue forKey:key];
    }
    
    return jsonStringDictionary;
}

@end
