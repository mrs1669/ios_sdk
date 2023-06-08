//
//  ADJGdprForgetStateData.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGdprForgetStateData.h"

#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJBooleanWrapper.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (readonly, assign, nonatomic) BOOL forgottenByBackend;
 @property (readonly, assign, nonatomic) BOOL askedToForgetBySdk;
 */
#pragma mark - Public constants
NSString *const ADJGdprForgetStateDataMetadataTypeValue = @"GdprForgetStateData";

#pragma mark - Private constants
static NSString *const kForgottenByBackendKey = @"forgottenByBackend";
static NSString *const kAskedToForgetBySdkKey = @"askedToForgetBySdk";

@implementation ADJGdprForgetStateData
#pragma mark Instantiation
+ (nonnull ADJResult<ADJGdprForgetStateData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData {
    ADJResultFail *_Nullable unexpectedMetadataTypeValueFail =
        [ioData isExpectedMetadataTypeValue:ADJGdprForgetStateDataMetadataTypeValue];
    if (unexpectedMetadataTypeValueFail != nil) {
        return [ADJResult failWithMessage:@"Cannot create gdpr forget state data from io data"
                                      key:@"unexpected metadata type value fail"
                                otherFail:unexpectedMetadataTypeValueFail];
    }

    ADJResult<ADJBooleanWrapper *> *_Nonnull forgottenByBackendResult =
        [ADJBooleanWrapper instanceFromIoValue:
         [ioData.propertiesMap pairValueWithKey:kForgottenByBackendKey]];
    if (forgottenByBackendResult.fail != nil) {
        return [ADJResult
                failWithMessage:@"Cannot create gdpr forget state data from io data"
                key:@"forgottenByBackend fail"
                otherFail:forgottenByBackendResult.fail];
    }

    ADJResult<ADJBooleanWrapper *> *_Nonnull askedToForgetBySdkResult =
        [ADJBooleanWrapper
         instanceFromIoValue:[ioData.propertiesMap pairValueWithKey:kAskedToForgetBySdkKey]];
    if (askedToForgetBySdkResult.fail != nil) {
        return [ADJResult
                failWithMessage:@"Cannot create gdpr forget state data from io data"
                key:@"askedToForgetBySdk fail"
                otherFail:askedToForgetBySdkResult.fail];
    }

    return [ADJResult okWithValue:
            [[ADJGdprForgetStateData alloc]
             initWithForgottenByBackend:forgottenByBackendResult.value.boolValue
             askedToForgetBySdk:askedToForgetBySdkResult.value.boolValue]];
}

+ (nullable ADJGdprForgetStateData *)instanceFromV4WithUserDefaults:
    (nonnull ADJV4UserDefaultsData *)v4UserDefaultsData
{
    if (v4UserDefaultsData.gdprForgetMeNumberBool == nil
        || ! v4UserDefaultsData.gdprForgetMeNumberBool)
    {
        return nil;
    }

    return [[ADJGdprForgetStateData alloc] initAskedButNotForgotten];
}
+ (nullable ADJGdprForgetStateData *)instanceFromV4WithActivityState:
    (nonnull ADJV4ActivityState *)v4ActivityState
{
    if (v4ActivityState.isGdprForgottenNumberBool == nil ||
        ! v4ActivityState.isGdprForgottenNumberBool)
    {
        return nil;
    }

    return [[ADJGdprForgetStateData alloc] initAskedButNotForgotten];
}

- (nonnull instancetype)initWithInitialState {
    return [self initWithForgottenByBackend:NO
                         askedToForgetBySdk:NO];
}

- (nonnull instancetype)initAskedButNotForgotten {
    return [self initWithForgottenByBackend:NO askedToForgetBySdk:YES];
}

- (nonnull instancetype)initForgottenByBackendWithAskedToForgetBySdk:(BOOL)askedToForgetBySdk {
    return [self initWithForgottenByBackend:YES
                         askedToForgetBySdk:askedToForgetBySdk];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithForgottenByBackend:(BOOL)forgottenByBackend
                                askedToForgetBySdk:(BOOL)askedToForgetBySdk {
    self = [super init];

    _forgottenByBackend = forgottenByBackend;
    _askedToForgetBySdk = askedToForgetBySdk;

    return self;
}

#pragma mark Public API
- (BOOL)isForgotten {
    return self.askedToForgetBySdk || self.forgottenByBackend;
}

#pragma mark - ADJIoDataSerializable
- (nonnull ADJIoData *)toIoData {
    ADJIoDataBuilder *_Nonnull ioDataBuilder =
    [[ADJIoDataBuilder alloc]
     initWithMetadataTypeValue:ADJGdprForgetStateDataMetadataTypeValue];

    ADJStringMapBuilder *_Nonnull propertiesMapBuilder = ioDataBuilder.propertiesMapBuilder;

    [ADJUtilMap
     injectIntoIoDataBuilderMap:propertiesMapBuilder
     key:kForgottenByBackendKey
     ioValueSerializable:[ADJBooleanWrapper instanceFromBool:self.forgottenByBackend]];

    [ADJUtilMap
     injectIntoIoDataBuilderMap:propertiesMapBuilder
     key:kAskedToForgetBySdkKey
     ioValueSerializable:[ADJBooleanWrapper instanceFromBool:self.askedToForgetBySdk]];

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJGdprForgetStateDataMetadataTypeValue,
            kForgottenByBackendKey, @(self.forgottenByBackend),
            kAskedToForgetBySdkKey, @(self.askedToForgetBySdk),
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + [@(self.forgottenByBackend) hash];
    hashCode = ADJHashCodeMultiplier * hashCode + [@(self.askedToForgetBySdk) hash];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJGdprForgetStateData class]]) {
        return NO;
    }

    ADJGdprForgetStateData *other = (ADJGdprForgetStateData *)object;
    return self.forgottenByBackend == other.forgottenByBackend
    && self.askedToForgetBySdk == other.askedToForgetBySdk;
}

@end

