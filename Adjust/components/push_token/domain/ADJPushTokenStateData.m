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
+ (nonnull ADJResultNN<ADJPushTokenStateData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData {
    ADJResultFail *_Nullable unexpectedMetadataTypeValueFail =
        [ioData isExpectedMetadataTypeValue:ADJPushTokenStateDataMetadataTypeValue];
    if (unexpectedMetadataTypeValueFail != nil) {
        return [ADJResultNN failWithMessage:@"Cannot create push token state data from io data"
                                        key:@"unexpected metadata type value fail"
                                  otherFail:unexpectedMetadataTypeValueFail];
    }

    ADJNonEmptyString *_Nullable lastPushToken =
        [ioData.propertiesMap pairValueWithKey:kLastPushTokenKey];

    return [ADJResultNN okWithValue:
            [[ADJPushTokenStateData alloc] initWithLastPushTokenString:lastPushToken]];
}

+ (nonnull ADJOptionalFailsNL<ADJPushTokenStateData *> *)
    instanceFromExternalWithPushTokenString:(nullable NSString *)pushTokenString
{
    ADJResultNL<ADJNonEmptyString *> *_Nullable pushTokenResult =
        [ADJNonEmptyString instanceFromOptionalString:pushTokenString];

    NSArray<ADJResultFail *> *_Nullable optionalFails = nil;
    if (pushTokenResult.fail != nil) {
        optionalFails = [NSArray arrayWithObject:
                         [[ADJResultFail alloc]
                          initWithMessage:
                              @"Could not parse external value for push token state data"
                          key:@"push token string fail"
                          otherFail:pushTokenResult.fail]];
    }

    if (pushTokenResult.value == nil) {
        return [[ADJOptionalFailsNL alloc] initWithOptionalFails:optionalFails value:nil];
    }

    return [[ADJOptionalFailsNL alloc]
            initWithOptionalFails:optionalFails
            value:[[ADJPushTokenStateData alloc]
                   initWithLastPushTokenString:pushTokenResult.value]];
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
