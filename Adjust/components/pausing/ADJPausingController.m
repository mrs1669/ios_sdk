//
//  ADJPausingController.m
//  Adjust
//
//  Created by Pedro S. on 06.03.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJPausingController.h"

#import "ADJPausingState.h"

#pragma mark Private class
@implementation ADJPausingPublisher @end

#pragma mark Fields
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJPausingPublisher *pausingPublisher;
 */

#pragma mark - Public constants
NSString *const ADJFromCanPublish = @"CanPublish";
NSString *const ADJResumeFromSdkStart = @"SdkStart";
NSString *const ADJResumeFromSdkActive = @"SdkActive";
NSString *const ADJPauseFromSdkNotActive = @"SdkNotActive";
NSString *const ADJResumeFromForeground = @"Foreground";
NSString *const ADJPauseFromBackground = @"Background";
NSString *const ADJResumeFromSdkOnline = @"SdkOnline";
NSString *const ADJPauseFromSdkOffline = @"SdkOffline";
NSString *const ADJResumeFromNetworkReachable = @"NetworkReachable";
NSString *const ADJPauseFromNetworkUnreachable = @"NetworkUnreachable";

@interface ADJPausingController ()
#pragma mark - Injected dependencies
@property (readonly, assign, nonatomic) BOOL canSendInBackground;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nonnull, readonly, strong, nonatomic) ADJPausingState *pausingState;

@end

@implementation ADJPausingController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    canSendInBackground:(BOOL)canSendInBackground
    publisherController:(nonnull ADJPublisherController *)publisherController
{

    self = [super initWithLoggerFactory:loggerFactory loggerName:@"PausingController"];
    _canSendInBackground = canSendInBackground;

    _pausingPublisher = [[ADJPausingPublisher alloc]
                         initWithSubscriberProtocol:@protocol(ADJPausingSubscriber)
                         controller:publisherController];

    _executor = [threadExecutorFactory
                 createSingleThreadExecutorWithLoggerFactory:loggerFactory
                 sourceLoggerName:self.logger.name];

    _pausingState = [[ADJPausingState alloc] initWithLoggerFactory:loggerFactory
                                               canSendInBackground:canSendInBackground];

    return self;
}

#pragma mark Public API
#pragma mark - ADJPublishingGateSubscriber
- (void)ccAllowedToPublishNotifications {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"allowed to publish notifications"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        BOOL publishPauseOrElseResume =
            [strongSelf.pausingState publishPauseOrElseResumeWhenCanPublish];

        if (publishPauseOrElseResume) {
            [strongSelf publishPauseSendingWithSource:ADJFromCanPublish];
        } else {
            [strongSelf publishResumeSendingWithSource:ADJFromCanPublish];
        }
    }];
}

#pragma mark - ADJOfflineSubscriber
- (void)didSdkBecomeOnline {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"sdk become online"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        BOOL publishResume =
            [strongSelf.pausingState publishResumeWhenOnlineWithSource:ADJResumeFromSdkOnline];

        if (publishResume) {
            [self publishResumeSendingWithSource:ADJResumeFromSdkOnline];
        }
    }];
}

- (void)didSdkBecomeOffline {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"sdk become offline"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        BOOL publishPause =
            [strongSelf.pausingState publishPauseWhenOfflineWithSource:ADJPauseFromSdkOffline];

        if (publishPause) {
            [self publishPauseSendingWithSource:ADJPauseFromSdkOffline];
        }
    }];
}

#pragma mark - ADJReachabilitySubscriber
- (void)didBecomeReachable {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"become reachable"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        BOOL publishResume =
            [strongSelf.pausingState
             publishResumeWhenNetworkIsReachableWithSource:ADJResumeFromNetworkReachable];

        if (publishResume) {
            [self publishResumeSendingWithSource:ADJResumeFromNetworkReachable];
        }
    }];
}

- (void)didBecomeUnreachable {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"become unreachable"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        BOOL publishPause =
            [strongSelf.pausingState
             publishPauseWhenNetworkIsUnreachableWithSource:ADJPauseFromNetworkUnreachable];

        if (publishPause) {
            [self publishPauseSendingWithSource:ADJPauseFromNetworkUnreachable];
        }
    }];
}

#pragma mark - ADJLifecycleSubscriber
- (void)ccDidForeground {
    if ([self.pausingState ignoringForegroundOrBackground]) {
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"foreground"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        BOOL publishResume =
            [strongSelf.pausingState
             publishResumeWhenForegroundWithSource:ADJResumeFromForeground];

        if (publishResume) {
            [self publishResumeSendingWithSource:ADJResumeFromForeground];
        }
    }];
}

- (void)ccDidBackground {
    if ([self.pausingState ignoringForegroundOrBackground]) {
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"background"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        BOOL publishPause =
            [strongSelf.pausingState
             publishPauseWhenBackgroundWithSource:ADJPauseFromBackground];

        if (publishPause) {
            [self publishPauseSendingWithSource:ADJPauseFromBackground];
        }
    }];
}

#pragma mark - ADJSdkStartSubscriber
- (void)ccSdkStart {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"sdk start"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        BOOL publishResume =
            [strongSelf.pausingState
             publishResumeWhenSdkStartWithSource:ADJResumeFromSdkStart];

        if (publishResume) {
            [self publishResumeSendingWithSource:ADJResumeFromSdkStart];
        }
    }];
}

#pragma mark - ADJSdkActiveSubscriber
- (void)ccSdkActiveWithStatus:(nonnull ADJSdkActiveStatus)status {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"sdk active"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        if ([ADJSdkActiveStatusActive isEqualToString:status]) {
            BOOL publishResume =
                [strongSelf.pausingState
                 publishResumeWhenSdkActiveWithSource:ADJResumeFromSdkActive];

            if (publishResume) {
                [self publishResumeSendingWithSource:ADJResumeFromSdkActive];
            }
        } else {
            BOOL publishPause =
                [strongSelf.pausingState
                 publishPauseWhenSdkNotActiveWithSource:ADJPauseFromSdkNotActive];

            if (publishPause) {
                [self publishPauseSendingWithSource:ADJPauseFromSdkNotActive];
            }
        }
    }];
}

#pragma mark Internal Methods
- (void)publishPauseSendingWithSource:(nonnull NSString *)source {
    [self.pausingPublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJPausingSubscriber> _Nonnull subscriber)
     {
        [subscriber didPauseSendingWithSource:source];
    }];
}

- (void)publishResumeSendingWithSource:(nonnull NSString *)source {
    [self.pausingPublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJPausingSubscriber> _Nonnull subscriber)
     {
        [subscriber didResumeSendingWithSource:source];
    }];
}

@end

