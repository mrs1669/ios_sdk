//
//  ADJClientPushTokenData.m
//  Adjust
//
//  Created by Aditi Agrawal on 30/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientPushTokenData.h"

#import "ADJUtilConv.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJUtilMap.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *pushTokenString;
 */

#pragma mark - Public constants
NSString *const ADJClientPushTokenDataMetadataTypeValue = @"ClientPushTokenData";

#pragma mark - Private constants
static NSString *const kPushTokenStringKey = @"pushTokenString";

@implementation ADJClientPushTokenData
+ (nullable instancetype)instanceFromClientWithAdjustPushToken:(nullable ADJAdjustPushToken *)adjustPushToken
                                                        logger:(nonnull ADJLogger *)logger {
    if (adjustPushToken == nil) {
        [logger errorClient:@"Cannot create push token with nil adjust push token"];
        return nil;
    }

    ADJResultNL<ADJNonEmptyString *> *_Nonnull pushTokenDataResult =
        [ADJNonEmptyString instanceFromOptionalString:
         [ADJUtilConv convertToBase64StringWithDataValue:adjustPushToken.dataPushToken]];

    if (pushTokenDataResult.value != nil) {
        return [[ADJClientPushTokenData alloc] initWithPushTokenString:pushTokenDataResult.value];
    }

    ADJResultNL<ADJNonEmptyString *> *_Nonnull pushTokenStringResult =
        [ADJNonEmptyString instanceFromOptionalString:adjustPushToken.stringPushToken];

    if (pushTokenStringResult.value != nil) {
        return [[ADJClientPushTokenData alloc] initWithPushTokenString:pushTokenStringResult.value];
    }

    if (pushTokenDataResult.failMessage != nil) {
        [logger errorClient:@"Cannot create push token with invalid data"
                failMessage:pushTokenDataResult.failMessage];
    } else if (pushTokenStringResult.failMessage != nil) {
        [logger errorClient:@"Cannot create push token with invalid string"
                failMessage:pushTokenDataResult.failMessage];
    } else {
        [logger errorClient:@"Cannot create push token with invalid data or string"];
    }

    return nil;
}

+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger {
    ADJStringMap *_Nonnull propertiesMap = clientActionInjectedIoData.propertiesMap;

    ADJNonEmptyString *_Nullable receiptDataString = [propertiesMap pairValueWithKey:kPushTokenStringKey];

    ADJAdjustPushToken *_Nonnull adjustPushToken = [[ADJAdjustPushToken alloc]
                                                    initWithStringPushToken:
                                                        receiptDataString != nil ? receiptDataString.stringValue : nil];

    return [ADJClientPushTokenData instanceFromClientWithAdjustPushToken:adjustPushToken
                                                                  logger:logger];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithPushTokenString:(nonnull ADJNonEmptyString *)pushTokenString {
    self = [super init];

    _pushTokenString = pushTokenString;

    return self;
}

#pragma mark Public API
#pragma mark - ADJClientActionIoDataInjectable
- (void)injectIntoClientActionIoDataBuilder:(nonnull ADJIoDataBuilder *)clientActionIoDataBuilder {
    ADJStringMapBuilder *_Nonnull propertiesMapBuilder =
    clientActionIoDataBuilder.propertiesMapBuilder;

    [ADJUtilMap injectIntoIoDataBuilderMap:propertiesMapBuilder
                                       key:kPushTokenStringKey
                       ioValueSerializable:self.pushTokenString];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJClientPushTokenDataMetadataTypeValue,
            kPushTokenStringKey, self.pushTokenString,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + self.pushTokenString.hash;

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJClientPushTokenData class]]) {
        return NO;
    }

    ADJClientPushTokenData *other = (ADJClientPushTokenData *)object;
    return [ADJUtilObj objectEquals:self.pushTokenString other:other.pushTokenString];
}

@end



