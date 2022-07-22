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
+ (nullable instancetype)instanceFromIoData:(nonnull ADJIoData *)ioData
                                     logger:(nonnull ADJLogger *)logger
{
    if (! [ioData
            isExpectedMetadataTypeValue:ADJMeasurementSessionStateDataMetadataTypeValue
            logger:logger])
    {
        return nil;
    }

    ADJMeasurementSessionData *_Nullable measurementSessionData = nil;

    ADJStringMap *_Nullable measurementSessionDataMap = [ioData mapWithName:kMeasurementSessionDataMapName];
    if (measurementSessionDataMap != nil) {
        measurementSessionData = [ADJMeasurementSessionData instanceFromIoDataMap:measurementSessionDataMap
                                                            logger:logger];
    }

    return [[self alloc] initWithMeasurementSessionData:measurementSessionData];
}

+ (nullable instancetype)
    instanceFromExternalWithMeasurementSessionData:(nullable ADJMeasurementSessionData *)measurementSessionData
    logger:(nonnull ADJLogger *)logger
{
    return [[self alloc] initWithMeasurementSessionData:measurementSessionData];
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

    return [[ADJIoData alloc] initWithIoDataBuider:ioDataBuilder];
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
