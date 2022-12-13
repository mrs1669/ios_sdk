//
//  ADJMeasurementSessionDataBuilder.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMeasurementSessionDataBuilder.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readwrite, strong, nonatomic) ADJTallyCounter *sessionCount;
 @property (nullable, readwrite, strong, nonatomic) ADJTimestampMilli *lastActivityTimestampMilli;
 @property (nullable, readwrite, strong, nonatomic) ADJTimeLengthMilli *sessionLengthMilli;
 @property (nullable, readwrite, strong, nonatomic) ADJTimeLengthMilli *timeSpentMilli;
 */

@interface ADJMeasurementSessionDataBuilder ()

@property (nullable, readwrite, strong, nonatomic) ADJTallyCounter *sessionCount;
@property (nullable, readwrite, strong, nonatomic) ADJTimestampMilli *lastActivityTimestampMilli;
@property (nullable, readwrite, strong, nonatomic) ADJTimeLengthMilli *sessionLengthMilli;
@property (nullable, readwrite, strong, nonatomic) ADJTimeLengthMilli *timeSpentMilli;

@end

@implementation ADJMeasurementSessionDataBuilder
#pragma mark Instantiation
- (nonnull instancetype)initWithPreFirstSessionData {
    // sessionCount, 0 before first session
    return [self initWithSessionCount:[ADJTallyCounter instanceStartingAtZero]
            // lastActivityTimestampMilli starts nil before first session
           lastActivityTimestampMilli:nil
            // sessionLengthMilli and timeSpentMilli, both initially null,
            //  since there are no previous sessions tracked,
            //  but needed to updated to non-null before saving to storage,
            //  to be able to be updated later on
                   sessionLengthMilli:nil
                       timeSpentMilli:nil];
}

- (nonnull instancetype)initWithSessionCount:(nullable ADJTallyCounter *)sessionCount
                  lastActivityTimestampMilli:(nullable ADJTimestampMilli *)lastActivityTimestampMilli
                          sessionLengthMilli:(nullable ADJTimeLengthMilli *)sessionLengthMilli
                              timeSpentMilli:(nullable ADJTimeLengthMilli *)timeSpentMilli {
    self = [super init];
    
    _sessionCount = sessionCount;
    _lastActivityTimestampMilli = lastActivityTimestampMilli;
    _sessionLengthMilli = sessionLengthMilli;
    _timeSpentMilli = timeSpentMilli;
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (void)incrementSessionCountWithLogger:(nonnull ADJLogger *)logger {
    if (self.sessionCount == nil) {
        [logger debugDev:@"Cannot increment session count with nil value"
               issueType:ADJIssueLogicError];
        return;
    }
    
    self.sessionCount = [self.sessionCount generateIncrementedCounter];
    
    [logger debugDev:@"Session count incremented"
                 key:@"session count"
               value:self.sessionCount.description];
}

- (void)setLastActivityTimestampMilli:(nonnull ADJTimestampMilli *)lastActivityTimestampMilli {
    _lastActivityTimestampMilli = lastActivityTimestampMilli;
}

- (void)setSessionLengthMilli:(nonnull ADJTimeLengthMilli *)sessionLengthMilli {
    _sessionLengthMilli = sessionLengthMilli;
}

- (void)setTimeSpentMilli:(nonnull ADJTimeLengthMilli *)timeSpentMilli {
    _timeSpentMilli = timeSpentMilli;
}

- (void)resetSessionIntervals {
    [self setSessionLengthMilli:[ADJTimeLengthMilli instanceWithoutTimeSpan]];
    [self setTimeSpentMilli:[ADJTimeLengthMilli instanceWithoutTimeSpan]];
}

@end
