//
//  ADJThreadController.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJThreadController.h"

#import "ADJPublisherBase.h"
#import "ADJUtilSys.h"

#pragma mark Private class
@interface ADJThreadExecutorAggregator : ADJPublisherBase<ADJSingleThreadExecutor *> @end

@implementation ADJThreadExecutorAggregator @end

@interface ADJThreadController ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic)
    ADJThreadExecutorAggregator *threadExecutorAggregator;
@property (readwrite, assign, nonatomic) BOOL hasFinalized;

@end

@implementation ADJThreadController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory {
    self = [super initWithLoggerFactory:loggerFactory source:@"ThreadController"];

    _threadExecutorAggregator = [[ADJThreadExecutorAggregator alloc] init];
    _hasFinalized = NO;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (void)executeInMainThreadWithBlock:(nonnull void (^)(void))blockToExecute {
    dispatch_async(dispatch_get_main_queue(), blockToExecute);
}

#pragma mark - ADJThreadPool
- (BOOL)executeAsyncWithBlock:(nonnull void (^)(void))blockToExecute {
    if (self.hasFinalized) {
        return NO;
    }

    dispatch_async([self backgroundAsyncDispatchQueue], blockToExecute);

    return YES;
}

- (BOOL)scheduleAsyncWithBlock:(nonnull void (^)(void))blockToSchedule
                delayTimeMilli:(nonnull ADJTimeLengthMilli *)delayTimeMilli
{
    if (delayTimeMilli.millisecondsSpan.uIntegerValue == 0) {
        return [self executeAsyncWithBlock:blockToSchedule];
    }

    if (self.hasFinalized) {
        return NO;
    }

    dispatch_after
        ([ADJUtilSys dispatchTimeWithMilli:delayTimeMilli.millisecondsSpan.uIntegerValue],
         [self backgroundAsyncDispatchQueue],
         blockToSchedule);

    return YES;
}

- (BOOL)
    executeSynchronouslyWithTimeout:(nonnull ADJTimeLengthMilli *)timeout
    blockToExecute:(nonnull void (^)(void))blockToExecute
{
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    BOOL canExecuteTask = [self executeAsyncWithBlock:^{
        blockToExecute();
        dispatch_semaphore_signal(semaphore);
    }];

    if (! canExecuteTask) {
        return NO;
    }

    intptr_t waitResult =
        dispatch_semaphore_wait(semaphore,
                                [ADJUtilSys
                                    dispatchTimeWithMilli:timeout.millisecondsSpan.uIntegerValue]);

    BOOL timedOut = waitResult != 0;

    return ! timedOut;
}

- (nonnull dispatch_queue_t)backgroundAsyncDispatchQueue {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

#pragma mark - ADJThreadExecutorFactory
- (nonnull ADJSingleThreadExecutor *)
    createSingleThreadExecutorWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    sourceDescription:(nonnull NSString *)sourceDescription
{
    ADJSingleThreadExecutor *_Nonnull singleThreadExecutor =
        [[ADJSingleThreadExecutor alloc] initWithLoggerFactory:loggerFactory
                                              sourceDescription:sourceDescription
                                                     threadPool:self];

    [self.threadExecutorAggregator addSubscriber:singleThreadExecutor];

    return singleThreadExecutor;
}

#pragma mark - ADJClientReturnExecutor
- (void)executeClientReturnWithBlock:(nonnull void (^)(void))blockToExecute {
    [self executeInMainThreadWithBlock:blockToExecute];
}

#pragma mark - ADJTeardownFinalizer
- (void)finalizeAtTeardown {
    if (self.hasFinalized) {
        return;
    }
    self.hasFinalized = YES;

    [self.threadExecutorAggregator notifySubscribersWithSubscriberBlock:
        ^(ADJSingleThreadExecutor *_Nonnull subscriber)
    {
        [subscriber finalizeAtTeardown];
    }];
}

#pragma mark - NSObject
- (void)dealloc {
    [self finalizeAtTeardown];
}

@end
