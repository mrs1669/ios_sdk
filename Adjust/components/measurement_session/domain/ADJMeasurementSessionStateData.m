//
//  ADJMeasurementSessionStateData.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMeasurementSessionStateData.h"

#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJMeasurementSessionData *measurementSessionData;
 */

#pragma mark - Public constants
NSString *const ADJMeasurementSessionStateDataMetadataTypeValue = @"MeasurementSessionStateData";

#pragma mark - Private constants
static NSString *const kMeasurementSessionDataMapName = @"2_SDK_SESSION_MAP";

@implementation ADJMeasurementSessionStateData
#pragma mark Instantiation
+ (nonnull ADJOptionalFailsNN<ADJResult<ADJMeasurementSessionStateData *> *> *)
    instanceFromIoData:(nonnull ADJIoData *)ioData
{
    ADJResultFail *_Nullable unexpectedMetadataTypeValueFail =
        [ioData isExpectedMetadataTypeValue:ADJMeasurementSessionStateDataMetadataTypeValue];
    if (unexpectedMetadataTypeValueFail != nil) {
        return [[ADJOptionalFailsNN alloc]
                initWithOptionalFails:nil
                value:[ADJResult
                       failWithMessage:@"Cannot create measurement session state data from io data"
                       key:@"unexpected metadata type value fail"
                       otherFail:unexpectedMetadataTypeValueFail]];
    }

    NSArray<ADJResultFail *> *_Nullable optionalFails = nil;
    ADJMeasurementSessionData *_Nullable measurementSessionData = nil;
    ADJStringMap *_Nullable measurementSessionDataMap =
        [ioData mapWithName:kMeasurementSessionDataMapName];

    if (measurementSessionDataMap != nil) {
        ADJResult<ADJMeasurementSessionData *> *_Nonnull measurementSessionDataResult =
            [ADJMeasurementSessionData instanceFromIoDataMap:measurementSessionDataMap];
        if (measurementSessionDataResult.fail != nil) {
            optionalFails = [NSArray arrayWithObject:
                             [[ADJResultFail alloc]
                              initWithMessage:@"Cannot use invalid measurement session data in"
                                " measurement session state data from io data"
                              key:@"measurementSessionData fail"
                              otherFail:measurementSessionDataResult.fail]];

        } else {
            measurementSessionData = measurementSessionDataResult.value;
        }
    }

    return [[ADJOptionalFailsNN alloc]
            initWithOptionalFails:optionalFails
            value:[ADJResult okWithValue:
                   [[ADJMeasurementSessionStateData alloc]
                    initWithMeasurementSessionData:measurementSessionData]]];
}

+ (nonnull ADJResult<ADJMeasurementSessionStateData *> *)
    instanceFromV4WithActivityState:(nullable ADJV4ActivityState *)v4ActivityState
{
    if (v4ActivityState == nil) {
        return [ADJResult nilInputWithMessage:
                @"Cannot create session data wiht nil v4 activity state"];
    }

    ADJResult<ADJMeasurementSessionData *> *_Nonnull sessionDataResult =
        [ADJMeasurementSessionData instanceFromV4WithActivityState:v4ActivityState];
    if (sessionDataResult.fail != nil) {
        return [ADJResult failWithMessage:@"Could not create session data from activity state"
                                      key:@"session data fail"
                                otherFail:sessionDataResult.fail];
    }

    return [ADJResult okWithValue:[[ADJMeasurementSessionStateData alloc]
                                   initWithMeasurementSessionData:sessionDataResult.value]];
}

- (nonnull instancetype)initWithIntialState {
    return [self initWithMeasurementSessionData:nil];
}

- (nonnull instancetype)initWithMeasurementSessionData:(nullable ADJMeasurementSessionData *)measurementSessionData {
    self = [super init];

    _measurementSessionData = measurementSessionData;

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
        [[ADJIoDataBuilder alloc]
            initWithMetadataTypeValue:ADJMeasurementSessionStateDataMetadataTypeValue];

    if (self.measurementSessionData != nil) {
        ADJStringMapBuilder *_Nonnull stringMapBuilder =
            [ioDataBuilder addAndReturnNewMapBuilderByName:kMeasurementSessionDataMapName];
        [self.measurementSessionData injectIntoIoDataMapBuilder:stringMapBuilder];
    }

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
                ADJMeasurementSessionStateDataMetadataTypeValue,
                    kMeasurementSessionDataMapName, self.measurementSessionData,
                nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode +
        [ADJUtilObj objecNullableHash:self.measurementSessionData];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJMeasurementSessionStateData class]]) {
        return NO;
    }

    ADJMeasurementSessionStateData *other = (ADJMeasurementSessionStateData *)object;
    return [ADJUtilObj objectEquals:self.measurementSessionData other:other.measurementSessionData];
}

@end
