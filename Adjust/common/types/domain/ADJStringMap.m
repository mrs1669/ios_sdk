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

//#import "ADJResultFail.h"

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

+ (nonnull ADJResult<ADJStringMap *> *)
    instanceFromIoValue:(nullable ADJNonEmptyString *)ioValue
{
    if (ioValue == nil) {
        return [ADJStringMap failInstanceFromIoValueWithReason:@"nil IoValue"
                                                   wasInputNil:YES
                                    foundationObjectResultFail:nil];
    }

    ADJResult<id> *_Nonnull foundationObjectResult =
        [ADJUtilConv convertToFoundationObjectWithJsonString:ioValue.stringValue];

    if (foundationObjectResult.fail != nil) {
        return [ADJStringMap
                failInstanceFromIoValueWithReason:
                    @"failed to convert json string into foundation object"
                foundationObjectResultFail:foundationObjectResult.fail];
    }
    if (! [foundationObjectResult.value isKindOfClass:[NSDictionary class]]) {
        return [ADJStringMap failInstanceFromIoValueWithReason:
                @"converted object from json string is not a dictionary"
                                    foundationObjectResultFail:nil];
    }

    NSDictionary *_Nonnull foundationDictionary = (NSDictionary *)foundationObjectResult.value;

    NSMutableDictionary <NSString *, ADJNonEmptyString *> *_Nonnull map =
        [NSMutableDictionary dictionaryWithCapacity:foundationDictionary.count];
    for (id _Nonnull keyObject in foundationDictionary) {
        ADJResult<ADJNonEmptyString *> *_Nonnull keyResult =
            [ADJNonEmptyString instanceFromObject:keyObject];
        if (keyResult.fail != nil) {
            return [ADJResult failWithMessage:@"Cannot create string map instance from IoValue"
                                          key:@"key convertion fail"
                                    otherFail:keyResult.fail];
        }

        id _Nullable valueObject = [foundationDictionary objectForKey:keyResult.value.stringValue];
        ADJResult<ADJNonEmptyString *> *_Nonnull valueResult =
            [ADJNonEmptyString instanceFromObject:valueObject];
        if (valueResult.fail != nil) {
            return [ADJResult failWithMessage:@"Cannot create string map instance from IoValue"
                                          key:@"value convertion fail"
                                    otherFail:valueResult.fail];
        }

        [map setObject:valueResult.value forKey:keyResult.value.stringValue];
    }

    ADJStringMap *_Nonnull instance = [[ADJStringMap alloc] initWithMap:[map copy]];

    dispatch_once(&(instance->_cachedJsonStringToken), ^{
        instance.cachedFoundationStringMap = foundationDictionary;

        instance.cachedJsonString = ioValue;
    });

    return [ADJResult okWithValue:instance];
}
+ (nonnull ADJResult<ADJStringMap *> *)
    failInstanceFromIoValueWithReason:(nonnull NSString *)why
    foundationObjectResultFail:(nullable ADJResultFail *)foundationObjectResultFail
{
    return [self failInstanceFromIoValueWithReason:why
                                       wasInputNil:NO
                        foundationObjectResultFail:foundationObjectResultFail];
}
+ (nonnull ADJResult<ADJStringMap *> *)
    failInstanceFromIoValueWithReason:(nonnull NSString *)why
    wasInputNil:(BOOL)wasInputNil
    foundationObjectResultFail:(nullable ADJResultFail *)foundationObjectResultFail
{
    return [ADJResult failWithMessage:@"Cannot create string map instance from IoValue"
                          wasInputNil:wasInputNil
                         builderBlock:^(ADJResultFailBuilder * _Nonnull resultFailBuilder) {
        [resultFailBuilder withKey:ADJLogWhyKey stringValue:why];
        if (foundationObjectResultFail != nil) {
            [resultFailBuilder withKey:@"convert json string to foundation object fail"
                             otherFail:foundationObjectResultFail];
        }
    }];
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
        
        ADJResult<ADJNonEmptyString *> *_Nonnull stringValueResult =
            [ADJUtilF jsonFoundationValueFormat:self.cachedFoundationStringMap];

        self.cachedJsonString = stringValueResult.value;
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
