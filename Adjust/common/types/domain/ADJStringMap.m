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

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readwrite, strong, nonatomic)
 NSDictionary<NSString *, ADJNonEmptyString*> *map;
 */

@interface ADJStringMap ()

#pragma mark - Internal variables
@property (nullable, readwrite, strong, nonatomic) ADJNonEmptyString *cachedJsonString;
@property (nullable, readwrite, strong, nonatomic)
NSDictionary<NSString *, NSString *> *cachedFoundationStringMap;

@end

@implementation ADJStringMap {
#pragma mark - Unmanaged variables
    dispatch_once_t _cachedJsonStringToken;
}

#pragma mark Instantiation
- (nonnull instancetype)initWithStringMapBuilder:(nonnull ADJStringMapBuilder *)stringMapBuilder {
    return [self initWithMap:[stringMapBuilder mapCopy]];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (nonnull ADJResultNN<ADJStringMap *> *)
    instanceFromIoValue:(nullable ADJNonEmptyString *)ioValue
{
    if (ioValue == nil) {
        return [ADJStringMap failInstanceFromIoValueWithReason:@"nil IoValue"];
    }

    NSError *_Nullable error = nil;
    id _Nullable foundationObject =
        [ADJUtilConv convertToFoundationObjectWithJsonString:ioValue.stringValue
                                                    errorPtr:&error];
    if (error != nil) {
        return [ADJStringMap failInstanceFromIoValueWithReason:
                [NSString stringWithFormat:
                 @"error converting json string into foundation object: %@",
                 [ADJUtilF errorFormat:error]]];
    }
    if (foundationObject == nil) {
        return [ADJStringMap failInstanceFromIoValueWithReason:
                @"converting json string into nil foundation object"];
    }
    if (! [foundationObject isKindOfClass:[NSDictionary class]]) {
        return [ADJStringMap failInstanceFromIoValueWithReason:
                @"converting json string into non dictionary foundation object"];
    }

    NSDictionary *_Nonnull foundationDictionary = (NSDictionary *)foundationObject;

    NSMutableDictionary <NSString *, ADJNonEmptyString *> *_Nonnull map =
        [NSMutableDictionary dictionaryWithCapacity:foundationDictionary.count];
    for (id _Nonnull keyObject in foundationDictionary) {
        ADJResultNN<ADJNonEmptyString *> *_Nonnull keyResult =
            [ADJNonEmptyString instanceFromObject:keyObject];
        if (keyResult.failMessage != nil) {
            return [ADJStringMap failInstanceFromIoValueWithReason:
                    [NSString stringWithFormat:@"invalid key: %@", keyResult.failMessage]];
        }

        id _Nullable valueObject = [foundationObject objectForKey:keyResult.value.stringValue];
        ADJResultNN<ADJNonEmptyString *> *_Nonnull valueResult =
            [ADJNonEmptyString instanceFromObject:valueObject];
        if (valueResult.failMessage != nil) {
            return [ADJStringMap failInstanceFromIoValueWithReason:
                [NSString stringWithFormat:@"invalid value: %@", valueResult.failMessage]];
        }

        [map setObject:valueResult.value forKey:keyResult.value.stringValue];
    }

    ADJStringMap *_Nonnull instance = [[ADJStringMap alloc] initWithMap:[map copy]];

    dispatch_once(&(instance->_cachedJsonStringToken), ^{
        instance.cachedFoundationStringMap = foundationDictionary;

        instance.cachedJsonString = ioValue;
    });

    return [ADJResultNN okWithValue:instance];
}
+ (nonnull ADJResultNN<ADJStringMap *> *)
    failInstanceFromIoValueWithReason:(nonnull NSString *)failReason
{
    return [ADJResultNN failWithMessage:
            [NSString stringWithFormat:
             @"Cannot create string map instance from IoValue with %@", failReason]];
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithMap:(nonnull NSDictionary<NSString *, ADJNonEmptyString*> *)map {
    self = [super init];
    
    _map = map;
    _cachedJsonString = nil;
    _cachedFoundationStringMap = nil;
    _cachedJsonStringToken = 0;
    
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

- (nonnull NSDictionary<NSString *, NSString *> *)foundationStringMap {
    [self injectCachedProperties];
    return self.cachedFoundationStringMap;
}

#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    [self injectCachedProperties];
    return self.cachedJsonString;
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    [self injectCachedProperties];
    if (self.cachedJsonString == nil) {
        return [[ADJNonEmptyString alloc] initWithConstStringValue:@"{}"];
    }
    return self.cachedJsonString;
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
- (void)injectCachedProperties {
    dispatch_once(&(self->_cachedJsonStringToken), ^{
        self.cachedFoundationStringMap = [self convertToFoundationStringMap];
        
        ADJResultErr<NSString *> *_Nonnull stringValueResult =
            [ADJUtilF jsonFoundationValueFormat:self.cachedFoundationStringMap];
        
        if (stringValueResult.value != nil) {
            self.cachedJsonString = [[ADJNonEmptyString alloc]
                                     initWithConstStringValue:stringValueResult.value];
        }
    });
}

- (nonnull NSDictionary<NSString *, NSString *> *)convertToFoundationStringMap {
    NSMutableDictionary<NSString *, NSString *> *_Nonnull foundationStringMap =
    [NSMutableDictionary dictionaryWithCapacity:self.map.count];
    
    for (NSString *_Nonnull key in self.map) {
        ADJNonEmptyString *_Nonnull value = [self.map objectForKey:key];
        [foundationStringMap setObject:value.stringValue forKey:key];
    }
    
    return foundationStringMap;
}

@end
