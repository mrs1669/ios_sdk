//
//  ADJMeasurementSessionDataBuilder.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJTallyCounter.h"
#import "ADJTimestampMilli.h"
#import "ADJTimeLengthMilli.h"
#import "ADJLogger.h"

@interface ADJMeasurementSessionDataBuilder : NSObject
// instantiation
- (nonnull instancetype)initWithPreFirstSessionData;
- (nonnull instancetype)
    initWithSessionCount:(nullable ADJTallyCounter *)sessionCount
    lastActivityTimestampMilli:(nullable ADJTimestampMilli *)lastActivityTimestampMilli
    sessionLengthMilli:(nullable ADJTimeLengthMilli *)sessionLengthMilli
    timeSpentMilli:(nullable ADJTimeLengthMilli *)timeSpentMilli
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJTallyCounter *sessionCount;
@property (nullable, readonly, strong, nonatomic) ADJTimestampMilli *lastActivityTimestampMilli;
@property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *sessionLengthMilli;
@property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *timeSpentMilli;

// public api
- (void)incrementSessionCountWithLogger:(nonnull ADJLogger *)logger;
- (void)setLastActivityTimestampMilli:(nonnull ADJTimestampMilli *)lastActivityTimestampMilli;
- (void)setSessionLengthMilli:(nonnull ADJTimeLengthMilli *)sessionLengthMilli;
- (void)setTimeSpentMilli:(nonnull ADJTimeLengthMilli *)timeSpentMilli;
- (void)resetSessionIntervals;

@end

