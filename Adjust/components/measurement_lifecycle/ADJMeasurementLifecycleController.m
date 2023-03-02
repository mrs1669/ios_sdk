//
//  ADJMeasurementLifecycleController.m
//  Adjust
//
//  Created by Pedro Silva on 01.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJMeasurementLifecycleController.h"

#import "ADJMeasurementLifecycleState.h"
#import "ADJTimerCycle.h"

#pragma mark Private class
@implementation ADJMeasurementLifecyclePublisher @end
@implementation ADJSdkStartPublisher @end
@implementation ADJKeepAlivePingPublisher @end

#pragma mark Fields
@interface ADJMeasurementLifecycleController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJSingleThreadExecutor *clientExecutorWeak;
@property (nullable, readonly, weak, nonatomic)
    ADJMeasurementSessionController *measurementSessionControllerWeak;
@property (nonnull, readonly, strong, nonatomic)
    ADJTimeLengthMilli *resumedSessionTimerStart;
@property (nonnull, readonly, strong, nonatomic)
    ADJTimeLengthMilli *resumedSessionTimerInterval;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJMeasurementLifecycleState *state;
@property (nonnull, readonly, strong, nonatomic) ADJTimerCycle *resumedSessionTimer;
@property (nonnull, readonly, strong, nonatomic)
    ADJMeasurementLifecyclePublisher *measurementLifecyclePublisher;
@property (nonnull, readonly, strong, nonatomic)
    ADJSdkStartPublisher *sdkStartPublisher;
@property (nonnull, readonly, strong, nonatomic) ADJKeepAlivePingPublisher *keepAlivePingPublisher;

@end

@implementation ADJMeasurementLifecycleController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
    measurementSessionController:
        (nonnull ADJMeasurementSessionController *)measurementSessionController
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    resumedSessionTimerStart:(nonnull ADJTimeLengthMilli *)resumedSessionTimerStart
    resumedSessionTimerInterval:(nonnull ADJTimeLengthMilli *)resumedSessionTimerInterval
    publisherController:(nonnull ADJPublisherController *)publisherController
{
    self = [super initWithLoggerFactory:loggerFactory source:@"MeasurementLifecycleController"];
    _clientExecutorWeak = clientExecutor;
    _measurementSessionControllerWeak = measurementSessionController;
    _resumedSessionTimerStart = resumedSessionTimerStart;
    _resumedSessionTimerInterval = resumedSessionTimerInterval;

    _sdkStartPublisher = [[ADJSdkStartPublisher alloc]
                          initWithSubscriberProtocol:@protocol(ADJSdkStartSubscriber)
                          controller:publisherController];

    _measurementLifecyclePublisher =
        [[ADJMeasurementLifecyclePublisher alloc]
         initWithSubscriberProtocol:@protocol(ADJMeasurementLifecycleSubscriber)
         controller:publisherController];

    _keepAlivePingPublisher = [[ADJKeepAlivePingPublisher alloc]
                               initWithSubscriberProtocol:@protocol(ADJKeepAlivePingSubscriber)
                               controller:publisherController];

    _state = [[ADJMeasurementLifecycleState alloc] initWithLoggerFactory:loggerFactory];

    _resumedSessionTimer = [[ADJTimerCycle alloc] init];

    return self;
}

#pragma mark Public API
- (void)ccPostSdkInit {
    ADJMeasurementLifecycleStateOutputData *_Nullable output = [self.state postSdkInit];
    [self ccHandleSideEffects:output];
}

#pragma mark - ADJSdkActiveSubscriber
- (void)ccSdkActiveWithStatus:(nonnull NSString *)status {
    [self.logger debugDev:@"Handling ccSdkActiveWithStatus"
                      key:@"status"
                    value:status];

    ADJMeasurementLifecycleStateOutputData *_Nullable output;
    if (ADJSdkActiveStatusActive == status) {
        output = [self.state sdkActive];
    } else {
        output = [self.state sdkNotActive];
    }

    [self ccHandleSideEffects:output];
}

#pragma mark - ADJLifecycleSubscriber
- (void)ccDidForeground {
    ADJMeasurementLifecycleStateOutputData *_Nullable output = [self.state foreground];
    [self ccHandleSideEffects:output];
}

- (void)ccDidBackground {
    ADJMeasurementLifecycleStateOutputData *_Nullable output = [self.state background];
    [self ccHandleSideEffects:output];
}

#pragma mark Internal Methods
- (void)ccHandleSideEffects:(nullable ADJMeasurementLifecycleStateOutputData *)output {
    if (output == nil) { return; }

    if (output.sdkStarted) {
        [self ccHandleSdkStart];
    }

    if (output.measurementResumed) {
        [self ccResumeMeasurementWithDidSdkStart:output.sdkStarted];
    }

    if (output.measurementPaused) {
        [self ccPauseMeasurement];
    }
}

- (void)ccHandleSdkStart {
    ADJMeasurementSessionController *_Nullable measurementSessionController =
        self.measurementSessionControllerWeak;
    if (measurementSessionController == nil) {
        [self.logger debugDev:
         @"Cannot ccHandleSdkStart without a reference to measurementSessionController"
                    issueType:ADJIssueWeakReference];
        return;
    }

    BOOL wasSdkStarted = [measurementSessionController ccTryStartSdk];
    if (! wasSdkStarted) { return; }

    [self.sdkStartPublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJSdkStartSubscriber> _Nonnull subscriber) {
        [subscriber ccSdkStart];
    }];
}

- (void)ccResumeMeasurementWithDidSdkStart:(BOOL)sdkStarted {
    [self.measurementLifecyclePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJMeasurementLifecycleSubscriber> _Nonnull subscriber) {
        [subscriber ccDidResumeMeasurementWithIsFirst:sdkStarted];
    }];

    __typeof(self) __weak weakSelf = self;
    void (^_Nonnull resumedSessionTimerFireBlock)(void)  = ^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf.keepAlivePingPublisher notifySubscribersWithSubscriberBlock:
         ^(id<ADJKeepAlivePingSubscriber> _Nonnull subscriber)
         {
            [subscriber didPingKeepAliveInActiveSession];
        }];
    };

    [self.resumedSessionTimer cycleWithDelayTimeMilli:self.resumedSessionTimerStart
                                        cycleInterval:self.resumedSessionTimerInterval
                                                block:resumedSessionTimerFireBlock];
}

- (void)ccPauseMeasurement {
    [self.measurementLifecyclePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJMeasurementLifecycleSubscriber> _Nonnull subscriber) {
        [subscriber ccDidPauseMeasurement];
    }];

    [self.resumedSessionTimer cancelDelayAndCycle];
}

@end
