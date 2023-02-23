//
//  ADJMeasurementLifecycleState.m
//  Adjust
//
//  Created by Pedro Silva on 01.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJMeasurementLifecycleState.h"

#import "ADJConstants.h"

#pragma mark Fields
/* .h
 @property (readonly, assign, nonatomic) BOOL sdkStarted;
 @property (readonly, assign, nonatomic) BOOL measurementResumed;
 @property (readonly, assign, nonatomic) BOOL measurementPaused;
 */

@implementation ADJMeasurementLifecycleStateOutputData
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
#pragma mark - Private constructors
- (nonnull instancetype)
    initWithSdkStarted:(BOOL)sdkStarted
    measurementResumed:(BOOL)measurementResumed
    measurementPaused:(BOOL)measurementPaused
{
    self = [super init];

    _sdkStarted = sdkStarted;
    _measurementResumed = measurementResumed;
    _measurementPaused = measurementPaused;

    return self;
}

- (nonnull instancetype)initWhenStartinSdk {
    return [self initWithSdkStarted:YES measurementResumed:YES measurementPaused:NO];
}

- (nonnull instancetype)initWhenResumingMeasurement {
    return [self initWithSdkStarted:NO measurementResumed:YES measurementPaused:NO];
}

- (nonnull instancetype)initWhenPausingMeasurement {
    return [self initWithSdkStarted:NO measurementResumed:NO measurementPaused:YES];
}

@end

@interface ADJMeasurementLifecycleState ()
#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL isOnForeground;
@property (readwrite, assign, nonatomic) BOOL isSdkActive;
@property (readwrite, assign, nonatomic) BOOL hasSdkInit;
@property (readwrite, assign, nonatomic) BOOL hasSdkStarted;
@property (readwrite, assign, nonatomic) BOOL isMeasurementResumed;

@end

@implementation ADJMeasurementLifecycleState
#pragma mark Instantiation
#pragma mark - Private constructors
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory {
    self = [super initWithLoggerFactory:loggerFactory source:@"MeasurementLifecycleState"];

    _isOnForeground = ADJIsSdkInForegroundWhenStarting;
    _isSdkActive = ADJIsSdkActiveWhenStarting;
    _hasSdkInit = NO;
    _hasSdkStarted = NO;
    _isMeasurementResumed = NO;

    return self;
}

#pragma mark - Private constructors
#pragma mark Public API
- (nullable ADJMeasurementLifecycleStateOutputData *)postSdkInit {
    if (self.hasSdkInit) {
        [self.logger debugDev:@"Cannot change since the sdk has already init"
                    issueType:ADJIssueUnexpectedInput];
        return nil;
    }
    self.hasSdkInit = YES;

    return [self tryToResumeMeasurement];
}

- (nullable ADJMeasurementLifecycleStateOutputData *)foreground {
    if (self.isOnForeground) {
        [self.logger debugDev:@"Cannot change since the app was already on the foreground"];
        return nil;
    }
    self.isOnForeground = YES;

    return [self tryToResumeMeasurement];
}
- (nullable ADJMeasurementLifecycleStateOutputData *)background {
    if (! self.isOnForeground) {
        [self.logger debugDev:@"Cannot change since the app was already on the background"];
        return nil;
    }
    self.isOnForeground = NO;

    return [self tryToPauseMeasurement];
}

- (nullable ADJMeasurementLifecycleStateOutputData *)sdkActive {
    if (self.isSdkActive) {
        [self.logger debugDev:@"Cannot change since the sdk was already active"];
        return nil;
    }
    self.isSdkActive = YES;

    return [self tryToResumeMeasurement];
}

- (nullable ADJMeasurementLifecycleStateOutputData *)sdkNotActive {
    if (! self.isSdkActive) {
        [self.logger debugDev:@"Cannot change since the sdk was already not active"];
        return nil;
    }
    self.isSdkActive = NO;

    return [self tryToPauseMeasurement];
}

#pragma mark Internal Methods
- (nullable ADJMeasurementLifecycleStateOutputData *)tryToResumeMeasurement {
    if (! self.hasSdkInit) {
        [self.logger debugDev:@"Cannot resume measurement when sdk has not init"];
        return nil;
    }
    if (! self.isSdkActive) {
        [self.logger debugDev:@"Cannot resume measurement when sdk is not active"];
        return nil;
    }
    if (! self.isOnForeground) {
        [self.logger debugDev:@"Cannot resume measurement when sdk is not on the foreground"];
        return nil;
    }
    if (self.isMeasurementResumed) {
        [self.logger debugDev:@"Cannot resume measurement when it was already resumed"
                    issueType:ADJIssueLogicError];
        return nil;
    }

    [self.logger debugDev:@"Will resume measurement"];
    self.isMeasurementResumed = YES;

    if (! self.hasSdkStarted) {
        [self.logger debugDev:@"Will start the sdk"];
        self.hasSdkStarted = YES;

        return [[ADJMeasurementLifecycleStateOutputData alloc] initWhenStartinSdk];
    }

    return [[ADJMeasurementLifecycleStateOutputData alloc] initWhenResumingMeasurement];
}

- (nullable ADJMeasurementLifecycleStateOutputData *)tryToPauseMeasurement {
    if (! self.hasSdkInit) {
        [self.logger debugDev:@"Cannot pause measurement when sdk has not init"];
        return nil;
    }
    if (! self.isMeasurementResumed) {
        [self.logger debugDev:@"Cannot pause measurement when it was already paused"];
        return nil;
    }
    if (! self.isSdkActive) {
        self.isMeasurementResumed = NO;

        if (! self.isOnForeground) {
            [self.logger debugDev:@"Will pause measurement because"
             " sdk is not active and app is not on the foreground"];
        } else {
            [self.logger debugDev:@"Will pause measurement because sdk is not active"];
        }

        return [[ADJMeasurementLifecycleStateOutputData alloc] initWhenPausingMeasurement];
    }

    if (! self.isOnForeground) {
        self.isMeasurementResumed = NO;

        [self.logger debugDev:@"Will pause measurement because app is not on the foreground"];

        return [[ADJMeasurementLifecycleStateOutputData alloc] initWhenPausingMeasurement];
    }

    [self.logger debugDev:@"Was not able to pause measurement"
                issueType:ADJIssueLogicError];

    return nil;
}

@end
