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
+ (nullable instancetype)instanceFromIoData:(nonnull ADJIoData *)ioData
                                     logger:(nonnull ADJLogger *)logger {
    if (! [ioData
           isExpectedMetadataTypeValue:ADJGdprForgetStateDataMetadataTypeValue
           logger:logger])
    {
        return nil;
    }

    ADJBooleanWrapper *_Nullable forgottenByBackend =
    [ADJBooleanWrapper
     instanceFromIoValue:
         [ioData.propertiesMap pairValueWithKey:kForgottenByBackendKey]
     logger:logger];

    if (forgottenByBackend == nil) {
        [logger error:@"Cannot create instance from Io data without valid %@",
         kForgottenByBackendKey];
        return nil;
    }

    ADJBooleanWrapper *_Nullable askedToForgetBySdk =
    [ADJBooleanWrapper
     instanceFromIoValue:
         [ioData.propertiesMap pairValueWithKey:kAskedToForgetBySdkKey]
     logger:logger];

    if (askedToForgetBySdk == nil) {
        [logger error:@"Cannot create instance from Io data without valid %@",
         kAskedToForgetBySdkKey];
        return nil;
    }

    return [[self alloc] initWithForgottenByBackend:forgottenByBackend.boolValue
                                 askedToForgetBySdk:askedToForgetBySdk.boolValue];
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
- (BOOL)isNotForgotten {
    return ! self.askedToForgetBySdk && ! self.forgottenByBackend;
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

