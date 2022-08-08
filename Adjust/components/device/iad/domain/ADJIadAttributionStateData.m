//
//  ADJ5IadAttributionStateData.m
//  Adjust
//
//  Created by Pedro S. on 31.07.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//
/*
#import "ADJ5IadAttributionStateData.h"

#import "ADJ5UtilMap.h"
#import "ADJ5UtilObj.h"
#import "ADJ5Constants.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJ5IadAttributionStateDataMetadataTypeValue = @"IadAttributionStateData";

#pragma mark - Public properties

#pragma mark - Private constants
static NSString *const kIadAttributionDataMapName = @"2_IAD_ATTRIBUTION_MAP";

@implementation ADJ5IadAttributionStateData
#pragma mark Instantiation
+ (nullable instancetype)instanceFromIoData:(nonnull ADJ5IoData *)ioData
                                     logger:(nonnull ADJ5Logger *)logger
{
    if (! [ioData
            isExpectedMetadataTypeValue:ADJ5IadAttributionStateDataMetadataTypeValue
            logger:logger])
    {
        return nil;
    }

    ADJ5IadAttributionData *_Nullable iadAttributionData = nil;

    ADJ5StringMap *_Nullable iadAttributionDataMap = [ioData mapWithName:kIadAttributionDataMapName];
    if (iadAttributionDataMap != nil) {
        iadAttributionData = [ADJ5IadAttributionData instanceFromIoDataMap:iadAttributionDataMap
                                                                    logger:logger];
    }

    return [[self alloc] initWithIadAttributionData:iadAttributionData];
}

- (nonnull instancetype)initWithIntialState {
    return [self initWithIadAttributionData:nil];
}

- (nonnull instancetype)initWithIadAttributionData:
    (nullable ADJ5IadAttributionData *)iadAttributionData
{
    self = [super init];

    _iadAttributionData = iadAttributionData;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
#pragma mark - ADJ5IoDataSerializable
- (nonnull ADJ5IoData *)toIoData {
    ADJ5IoDataBuilder *_Nonnull ioDataBuilder =
        [[ADJ5IoDataBuilder alloc]
            initWithMetadataTypeValue:ADJ5IadAttributionStateDataMetadataTypeValue];

    if (self.iadAttributionData != nil) {
        ADJ5StringMapBuilder *_Nonnull stringMapBuilder =
            [ioDataBuilder addAndReturnNewMapBuilderByName:
                kIadAttributionDataMapName];
        [self.iadAttributionData injectIntoIoDataMapBuilder:stringMapBuilder];
    }

    return [[ADJ5IoData alloc] initWithIoDataBuider:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJ5UtilObj formatInlineKeyValuesWithName:
                ADJ5IadAttributionStateDataMetadataTypeValue,
                    kIadAttributionDataMapName, self.iadAttributionData,
                nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJ5InitialHashCode;

    hashCode = ADJ5HashCodeMultiplier * hashCode +
        [ADJ5UtilObj objecNullableHash:self.iadAttributionData];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJ5IadAttributionStateData class]]) {
        return NO;
    }

    ADJ5IadAttributionStateData *other = (ADJ5IadAttributionStateData *)object;
    return [ADJ5UtilObj objectEquals:self.iadAttributionData other:other.iadAttributionData];
}

@end
*/
