//
//  ADJKeepAliveController.m
//  Adjust
//
//  Created by Pedro S. on 16.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJKeepAliveController.h"

#import "ADJTimerCycle.h"
#import "ADJConstants.h"

#pragma mark Private class
@implementation ADJKeepAlivePublisher @end

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic)
 ADJKeepAlivePublisher *keepAlivePublisher;
 */

@interface ADJKeepAliveController ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *foregroundTimerStartMilli;
@property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *foregroundTimerIntervalMilli;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nonnull, readonly, strong, nonatomic) ADJTimerCycle *foregroundTimer;
@property (readwrite, assign, nonatomic) BOOL isOnForeground;
@property (readwrite, assign, nonatomic) BOOL hasMeasurementSessionStarted;

@end

@implementation ADJKeepAliveController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    foregroundTimerStartMilli:(nonnull ADJTimeLengthMilli *)foregroundTimerStartMilli
    foregroundTimerIntervalMilli:(nonnull ADJTimeLengthMilli *)foregroundTimerIntervalMilli
    publisherController:(nonnull ADJPublisherController *)publisherController
{

    self = [super initWithLoggerFactory:loggerFactory source:@"KeepAliveController"];
    _foregroundTimerStartMilli = foregroundTimerStartMilli;
    _foregroundTimerIntervalMilli = foregroundTimerIntervalMilli;
    
    _keepAlivePublisher = [[ADJKeepAlivePublisher alloc]
                           initWithSubscriberProtocol:@protocol(ADJKeepAliveSubscriber)
                           controller:publisherController];
    
    _executor = [threadExecutorFactory createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                                 sourceDescription:self.source];
    
    _foregroundTimer = [[ADJTimerCycle alloc] init];
    
    _isOnForeground = ADJIsSdkInForegroundWhenStarting;
    
    _hasMeasurementSessionStarted = NO;
    
    return self;
}

#pragma mark - ADJMeasurementSessionStartSubscriber
- (void)ccMeasurementSessionStartWithStatus:(nonnull NSString *)measurementSessionStartStatus {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        strongSelf.hasMeasurementSessionStarted = YES;
        
        if (strongSelf.isOnForeground) {
            [strongSelf startForegroundTimer];
        }
    } source:@"measurement session start"];
}

#pragma mark - ADJLifecycleSubscriber
- (void)onForegroundWithIsFromClientContext:(BOOL)isFromClientContext {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        strongSelf.isOnForeground = YES;
        
        if (strongSelf.hasMeasurementSessionStarted) {
            [strongSelf startForegroundTimer];
        }
    } source:@"foreground"];
}
- (void)onBackgroundWithIsFromClientContext:(BOOL)isFromClientContext {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        strongSelf.isOnForeground = NO;
        
        [strongSelf.foregroundTimer cancelDelayAndCycle];
    } source:@"background"];
}

#pragma mark Internal Methods
- (void)startForegroundTimer {
    __typeof(self) __weak weakSelf = self;
    void (^_Nonnull didForegroundTimerFireBlock)(void)  = ^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf didForegroundTimerFire];
    };
    
    [self.foregroundTimer cycleWithDelayTimeMilli:self.foregroundTimerStartMilli
                                    cycleInterval:self.foregroundTimerIntervalMilli
                                            block:didForegroundTimerFireBlock];
}

- (void)didForegroundTimerFire {
    [self.keepAlivePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJKeepAliveSubscriber> _Nonnull subscriber)
     {
        [subscriber didKeepAlivePing];
    }];
}

@end
