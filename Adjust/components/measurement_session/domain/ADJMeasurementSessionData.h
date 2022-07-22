//
//  ADJMeasurementSessionData.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataMapBuilderInjectable.h"
#import "ADJLogger.h"
#import "ADJMeasurementSessionDataBuilder.h"
#import "ADJStringMap.h"
#import "ADJTallyCounter.h"
#import "ADJTimestampMilli.h"
#import "ADJTimeLengthMilli.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJMeasurementSessionDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJMeasurementSessionData : NSObject<ADJIoDataMapBuilderInjectable>
// instantiation
+ (nullable instancetype)instanceFromIoDataMap:(nonnull ADJStringMap *)ioDataMap
                                        logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)
    instanceFromBuilder:(nonnull ADJMeasurementSessionDataBuilder *)measurementSessionDataBuilder
    logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)
    instanceFromExternalWithSessionCountNumberInt:
        (nullable NSNumber *)sessionCountNumberInt
    lastActivityTimestampNumberDoubleSeconds:
        (nullable NSNumber *)lastActivityTimestampNumberDoubleSeconds
    sessionLengthNumberDoubleSeconds:(nullable NSNumber *)sessionLengthNumberDoubleSeconds
    timeSpentNumberDoubleSeconds:(nullable NSNumber *)timeSpentNumberDoubleSeconds
    logger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJTallyCounter *sessionCount;
@property (nonnull, readonly, strong, nonatomic) ADJTimestampMilli *lastActivityTimestampMilli;
@property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *sessionLengthMilli;
@property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *timeSpentMilli;

// public api
- (nonnull ADJMeasurementSessionDataBuilder *)toMeasurementSessionDataBuilder;

@end
