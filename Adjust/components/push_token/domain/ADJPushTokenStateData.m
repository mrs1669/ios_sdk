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
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *lastPushToken;
 */
#pragma mark - Public constants
NSString *const ADJPushTokenStateDataMetadataTypeValue = @"PushTokenStateData";

#pragma mark - Private constants
static NSString *const kLastPushTokenKey = @"lastPushToken";

@implementation ADJPushTokenStateData
#pragma mark Instantiation
+ (nonnull ADJResult<ADJPushTokenStateData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData {
    ADJResultFail *_Nullable unexpectedMetadataTypeValueFail =
        [ioData isExpectedMetadataTypeValue:ADJPushTokenStateDataMetadataTypeValue];
    if (unexpectedMetadataTypeValueFail != nil) {
        return [ADJResult failWithMessage:@"Cannot create push token state data from io data"
                                      key:@"unexpected metadata type value fail"
                                otherFail:unexpectedMetadataTypeValueFail];
    }

    ADJNonEmptyString *_Nullable lastPushToken =
        [ioData.propertiesMap pairValueWithKey:kLastPushTokenKey];

    return [ADJResult okWithValue:
            [[ADJPushTokenStateData alloc] initWithLastPushTokenString:lastPushToken]];
}

- (nonnull instancetype)initWithInitialState {
    return [self initWithLastPushTokenString:nil];
}

- (nonnull instancetype)initWithLastPushTokenString:(nullable ADJNonEmptyString *)lastPushToken {
    self = [super init];

    _lastPushToken = lastPushToken;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
#pragma mark - ADJIoDataSerializable
- (nonnull ADJIoData *)toIoData {
    ADJIoDataBuilder *_Nonnull ioDataBuilder =
        [[ADJIoDataBuilder alloc] initWithMetadataTypeValue:ADJPushTokenStateDataMetadataTypeValue];
    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
                                       key:kLastPushTokenKey
                       ioValueSerializable:self.lastPushToken];

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJPushTokenStateDataMetadataTypeValue,
            kLastPushTokenKey, self.lastPushToken,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier *
        hashCode + [ADJUtilObj objecNullableHash:self.lastPushToken];

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
    return [ADJUtilObj objectEquals:self.lastPushToken other:other.lastPushToken];
}

@end
