//
//  ADJPackageSessionData.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJPackageSessionData.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJTallyCounter *sessionCount;
 @property (nullable, readonly, strong, nonatomic) ADJTimestampMilli *lastActivityTimestampMilli;
 @property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *sessionLengthMilli;
 @property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *timeSpentMilli;
 */

@implementation ADJPackageSessionData
// instantiation
- (nonnull instancetype)initWithBuilder:
    (nonnull ADJMeasurementSessionDataBuilder *)measurementSessionDataBuilder
{
    return [self initWithSessionCount:measurementSessionDataBuilder.sessionCount
           lastActivityTimestampMilli:measurementSessionDataBuilder.lastActivityTimestampMilli
                   sessionLengthMilli:measurementSessionDataBuilder.sessionLengthMilli
                       timeSpentMilli:measurementSessionDataBuilder.timeSpentMilli];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)
    initWithSessionCount:(nullable ADJTallyCounter *)sessionCount
    lastActivityTimestampMilli:(nullable ADJTimestampMilli *)lastActivityTimestampMilli
    sessionLengthMilli:(nullable ADJTimeLengthMilli *)sessionLengthMilli
    timeSpentMilli:(nullable ADJTimeLengthMilli *)timeSpentMilli
{
    self = [super init];

    _sessionCount = sessionCount;
    _lastActivityTimestampMilli = lastActivityTimestampMilli;
    _sessionLengthMilli = sessionLengthMilli;
    _timeSpentMilli = timeSpentMilli;

    return self;
}

@end
