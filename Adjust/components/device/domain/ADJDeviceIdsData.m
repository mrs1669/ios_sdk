//
//  ADJDeviceIdsData.m
//  Adjust
//
//  Created by Pedro S. on 23.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJDeviceIdsData.h"

#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *uuid;
 */
#pragma mark - Public constants
NSString *const ADJDeviceIdsDataMetadataTypeValue = @"DeviceIdsData";

#pragma mark - Private constants
static NSString *const kUuidKey = @"uuid";

@implementation ADJDeviceIdsData
#pragma mark Instantiation
+ (nullable instancetype)instanceFromIoData:(nonnull ADJIoData *)ioData
                                     logger:(nonnull ADJLogger *)logger {
    if (! [ioData
           isExpectedMetadataTypeValue:ADJDeviceIdsDataMetadataTypeValue
           logger:logger])
    {
        return nil;
    }

    ADJNonEmptyString *_Nullable uuid =
    [ioData.propertiesMap pairValueWithKey:kUuidKey];

    return [[self alloc] initWithUuid:uuid];
}

- (nonnull instancetype)initWithInitialState {
    return [self initWithUuid:nil];
}

- (nonnull instancetype)initWithUuid:(nullable ADJNonEmptyString *)uuid {
    self = [super init];

    _uuid = uuid;

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
     initWithMetadataTypeValue:ADJDeviceIdsDataMetadataTypeValue];

    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
                                       key:kUuidKey
                       ioValueSerializable:self.uuid];

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJDeviceIdsDataMetadataTypeValue,
            kUuidKey, self.uuid,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + [ADJUtilObj objecNullableHash:self.uuid];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJDeviceIdsData class]]) {
        return NO;
    }

    ADJDeviceIdsData *other = (ADJDeviceIdsData *)object;
    return [ADJUtilObj objectEquals:self.uuid other:other.uuid];
}

@end



