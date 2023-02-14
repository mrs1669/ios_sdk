//
//  ADJPushTokenStateData.m
//  Adjust
//
//  Created by Aditi Agrawal on 13/02/23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJPushTokenStateData.h"

#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *cachedPushTokenString;
 */
#pragma mark - Public constants
NSString *const ADJPushTokenMetadataTypeValue = @"PushTokenStringData";

#pragma mark - Private constants
static NSString *const kCachedPushTokenStringKey = @"cachedPushTokenString";

@implementation ADJPushTokenStateData
#pragma mark Instantiation
+ (nullable instancetype)instanceFromIoData:(nonnull ADJIoData *)ioData
                                     logger:(nonnull ADJLogger *)logger {
    if (! [ioData isExpectedMetadataTypeValue:ADJPushTokenMetadataTypeValue
                                       logger:logger]) {
        return nil;
    }

    ADJNonEmptyString *_Nullable pushTokenString = [ioData.propertiesMap pairValueWithKey:kCachedPushTokenStringKey];

    return [[self alloc] initWithPushTokenString:pushTokenString];
}

- (nonnull instancetype)initWithInitialState {
    return [self initWithPushTokenString:nil];
}

- (nonnull instancetype)initWithPushTokenString:(nullable ADJNonEmptyString *)pushTokenString {
    self = [super init];

    _cachedPushTokenString = pushTokenString;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
#pragma mark - ADJIoDataSerializable
- (nonnull ADJIoData *)toIoData {
    ADJIoDataBuilder *_Nonnull ioDataBuilder = [[ADJIoDataBuilder alloc]
                                                initWithMetadataTypeValue:ADJPushTokenMetadataTypeValue];
    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
                                       key:kCachedPushTokenStringKey
                       ioValueSerializable:self.cachedPushTokenString];

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJPushTokenMetadataTypeValue,
            kCachedPushTokenStringKey, self.cachedPushTokenString,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.cachedPushTokenString];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJPushTokenStateData class]]) {
        return NO;
    }

    ADJPushTokenStateData *other = (ADJPushTokenStateData *)object;
    return [ADJUtilObj objectEquals:self.cachedPushTokenString other:other.cachedPushTokenString];
}

@end


