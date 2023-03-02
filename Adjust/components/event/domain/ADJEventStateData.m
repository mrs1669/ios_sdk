//
//  ADJEventStateData.m
//  Adjust
//
//  Created by Aditi Agrawal on 03/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJEventStateData.h"

#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJTallyCounter *eventCount;
 */

#pragma mark - Public constants
NSString *const ADJEventStateDataMetadataTypeValue = @"EventStateData";

#pragma mark - Private constants
static NSString *const kEventCountKey = @"eventCount";

@implementation ADJEventStateData
#pragma mark Instantiation
+ (nullable instancetype)instanceFromIoData:(nonnull ADJIoData *)ioData
                                     logger:(nonnull ADJLogger *)logger {
    if (! [ioData
           isExpectedMetadataTypeValue:ADJEventStateDataMetadataTypeValue
           logger:logger])
    {
        return nil;
    }

    ADJResultNN<ADJTallyCounter *> *_Nonnull eventCountResult =
        [ADJTallyCounter instanceFromIoDataValue:
         [ioData.propertiesMap pairValueWithKey:kEventCountKey]];
    if (eventCountResult.fail != nil) {
        [logger debugDev:@"Cannot create instance from Io data invalid io value"
                 subject:kEventCountKey
              resultFail:eventCountResult.fail
               issueType:ADJIssueStorageIo];
        return nil;
    }

    return [[self alloc] initWithEventCount:eventCountResult.value];
}

+ (nullable instancetype)
    instanceFromExternalWithEventCountNumberInt:(nonnull NSNumber *)eventCountNumberInt    
    logger:(nonnull ADJLogger *)logger
{
    ADJResultNL<ADJNonNegativeInt *> *_Nonnull eventCountIntResult =
        [ADJNonNegativeInt instanceFromOptionalIntegerNumber:eventCountNumberInt];

    if (eventCountIntResult.fail != nil) {
        [logger debugDev:@"Invalid event count from external"
              resultFail:eventCountIntResult.fail
               issueType:ADJIssueExternalApi];
        return nil;
    }

    return [[self alloc] initWithEventCount:
            [[ADJTallyCounter alloc] initWithCountValue:eventCountIntResult.value]];
}

- (nonnull instancetype)initWithIntialState {
    return [self initWithEventCount:[ADJTallyCounter instanceStartingAtZero]];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithEventCount:(nonnull ADJTallyCounter *)eventCount {
    self = [super init];

    _eventCount = eventCount;

    return self;
}

#pragma mark Public API
- (nonnull ADJEventStateData *)generateIncrementedEventCountStateData {
    return [[ADJEventStateData alloc] initWithEventCount:
            [self.eventCount generateIncrementedCounter]];
}

#pragma mark - ADJIoDataSerializable
- (nonnull ADJIoData *)toIoData {
    ADJIoDataBuilder *_Nonnull ioDataBuilder =
    [[ADJIoDataBuilder alloc]
     initWithMetadataTypeValue:ADJEventStateDataMetadataTypeValue];

    [ADJUtilMap
     injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
     key:kEventCountKey
     ioValueSerializable:self.eventCount];

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJEventStateDataMetadataTypeValue,
            kEventCountKey, self.eventCount,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + self.eventCount.hash;

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJEventStateData class]]) {
        return NO;
    }

    ADJEventStateData *other = (ADJEventStateData *)object;
    return [ADJUtilObj objectEquals:self.eventCount other:other.eventCount];
}

@end

