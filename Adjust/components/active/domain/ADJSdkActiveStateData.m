//
//  ADJSdkActiveStateData.m
//  AdjustV5
//
//  Created by Pedro S. on 21.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJSdkActiveStateData.h"

#import "ADJBooleanWrapper.h"
#import "ADJIoDataBuilder.h"
#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonatomic, assign) BOOL isSdkActive;
 */
#pragma mark - Public constants
NSString *const ADJSdkActiveStateDataMetadataTypeValue = @"SdkActiveStateData";

#pragma mark - Private constants
static NSString *const kIsSdkActiveKey = @"isSdkActive";

@implementation ADJSdkActiveStateData
#pragma mark Instantiation
+ (nonnull ADJResultNN<ADJSdkActiveStateData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData {
    ADJResultFail *_Nullable unexpectedMetadataTypeValueFail =
        [ioData isExpectedMetadataTypeValue:ADJSdkActiveStateDataMetadataTypeValue];
    if (unexpectedMetadataTypeValueFail != nil) {
        return [ADJResultNN failWithMessage:@"Cannot create sdk active state data from io data"
                                        key:@"unexpected metadata type value fail"
                                  otherFail:unexpectedMetadataTypeValueFail];
    }

    ADJResultNN<ADJBooleanWrapper *> *_Nonnull isSdkActiveResult =
        [ADJBooleanWrapper
            instanceFromIoValue:[ioData.propertiesMap pairValueWithKey:kIsSdkActiveKey]];

    if (isSdkActiveResult.fail != nil) {
        return [ADJResultNN failWithMessage:@"Cannot create sdk active state data from io data"
                                        key:@"isSdkActive fail"
                                  otherFail:isSdkActiveResult.fail];
    }

    return [ADJResultNN okWithValue:
            [[ADJSdkActiveStateData alloc] initWithIsActiveSdk:isSdkActiveResult.value.boolValue]];
}

- (nonnull instancetype)initWithInitialState {
    return [self initWithActiveSdk];
}

- (nonnull instancetype)initWithActiveSdk {
    return [self initWithIsActiveSdk:YES];
}

- (nonnull instancetype)initWithInactiveSdk {
    return [self initWithIsActiveSdk:NO];
}

+ (nullable ADJSdkActiveStateData *)instanceFromV4WithActivityState:
    (nullable ADJV4ActivityState *)v4ActivityState
{
    if (v4ActivityState == nil || v4ActivityState.enableNumberBool == nil) {
        return nil;
    }

    if (v4ActivityState.enableNumberBool.boolValue) {
        return [[ADJSdkActiveStateData alloc] initWithActiveSdk];
    } else {
        return [[ADJSdkActiveStateData alloc] initWithInactiveSdk];
    }
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithIsActiveSdk:(BOOL)isSdkActive {
    self = [super init];

    _isSdkActive = isSdkActive;

    return self;
}

#pragma mark Public API
#pragma mark - ADJIoDataSerializable
- (nonnull ADJIoData *)toIoData {
    ADJIoDataBuilder *_Nonnull ioDataBuilder =
        [[ADJIoDataBuilder alloc]
         initWithMetadataTypeValue:ADJSdkActiveStateDataMetadataTypeValue];

    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
                                       key:kIsSdkActiveKey
                       ioValueSerializable:[ADJBooleanWrapper instanceFromBool:self.isSdkActive]];

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJSdkActiveStateDataMetadataTypeValue,
            kIsSdkActiveKey, @(self.isSdkActive),
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + [@(self.isSdkActive) hash];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJSdkActiveStateData class]]) {
        return NO;
    }

    ADJSdkActiveStateData *other = (ADJSdkActiveStateData *)object;
    return self.isSdkActive == other.isSdkActive;
}

@end
