//
//  ADJMeasurementSessionState.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJTimeLengthMilli.h"
#import "ADJMeasurementSessionStateData.h"
#import "ADJValueWO.h"
#import "ADJMeasurementSessionData.h"
#import "ADJPackageSessionData.h"
#import "ADJTimestampMilli.h"

@interface ADJMeasurementSessionStateOutputData : NSObject

@property (nullable, readonly, strong, nonatomic) ADJMeasurementSessionStateData *changedStateData;
@property (nullable, readonly, strong, nonatomic) ADJPackageSessionData *packageSessionData;

- (nullable instancetype)init NS_UNAVAILABLE;

@end

@interface ADJMeasurementSessionState : ADJCommonBase
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    initialMeasurementSessionStateData:
        (nonnull ADJMeasurementSessionStateData *)initialMeasurementSessionStateData
    overwriteFirstSdkSessionInterval:
        (nullable ADJTimeLengthMilli *)overwriteFirstSdkSessionInterval
    minMeasurementSessionInterval:
        (nonnull ADJTimeLengthMilli *)minMeasurementSessionInterval;

// public api
- (nullable ADJMeasurementSessionStateOutputData *)sdkStartWithNonMonotonicNowTimestamp:
    (nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp;

- (nullable ADJMeasurementSessionStateOutputData *)resumeMeasurementWithNowTimestamp:
    (nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp;

- (nullable ADJMeasurementSessionStateOutputData *)pauseMeasurementWithNowTimestamp:
    (nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp;

- (nullable ADJMeasurementSessionStateOutputData *)keepAlivePingWithNonMonotonicNowTimestamp:
    (nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp;

@end
