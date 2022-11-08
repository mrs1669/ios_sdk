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
#import "ADJLocalThreadController.h"

#pragma mark Private class
@interface ADJThreadExecutorAggregator : ADJPublisherBase<ADJSingleThreadExecutor *> @end

@implementation ADJThreadExecutorAggregator @end

#pragma mark Fields
@interface ADJThreadController ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) dispatch_queue_t concurrentQueue;
@property (nonnull, readonly, strong, nonatomic)
    ADJThreadExecutorAggregator *threadExecutorAggregator;
@property (readwrite, assign, nonatomic) BOOL hasFinalized;

@end

@implementation ADJThreadController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory {
    self = [super initWithLoggerFactory:loggerFactory source:@"ThreadController"];

    _concurrentQueue = dispatch_queue_create(self.source.UTF8String, DISPATCH_QUEUE_CONCURRENT);
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

#pragma mark - ADJThreadExecutorFactory
- (nonnull ADJSingleThreadExecutor *)
    createSingleThreadExecutorWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    sourceDescription:(nonnull NSString *)sourceDescription
{
    ADJSingleThreadExecutor *_Nonnull singleThreadExecutor =
        [[ADJSingleThreadExecutor alloc] initWithLoggerFactory:loggerFactory
                                             sourceDescription:sourceDescription];

    [self.threadExecutorAggregator addSubscriber:singleThreadExecutor];

    return singleThreadExecutor;
}

#pragma mark - ADJClientReturnExecutor
- (void)executeClientReturnWithBlock:(nonnull void (^)(void))blockToExecute {
    [self executeInMainThreadWithBlock:blockToExecute];
}

#pragma mark - ADJThreadExecutorFactory
- (BOOL)executeAsyncWithBlock:(nonnull void (^)(void))blockToExecute
                       source:(nonnull NSString *)source
{
    if (self.hasFinalized) {
        return NO;
    }

    __block ADJLocalThreadController *_Nonnull localThreadController =
        [ADJLocalThreadController instance];

    NSString *_Nonnull callerLocalId = [localThreadController localIdOrOutside];

    __typeof(self) __weak weakSelf = self;
    dispatch_async(self.concurrentQueue, ^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        NSString *_Nonnull runningLocalId =
            [localThreadController setNextLocalIdInConcurrentThread];
        
        // no need to check for skip trace local id,
        //  since there is no async executions downstream of the log collection.
        //  If/when that changes, it will be necessary to check here
        [strongSelf.logger traceThreadChangeWithCallerThreadId:callerLocalId
                                               runningThreadId:runningLocalId
                                             callerDescription:source];
        
        blockToExecute();

        // because the thread can be reused by an outside execution
        //  it needs to be clear to avoid reading it again by mistake
        [localThreadController removeLocalIdInConcurrentThread];
    });

    return YES;
}

- (BOOL)
    executeSynchronouslyWithTimeout:(nonnull ADJTimeLengthMilli *)timeout
    blockToExecute:(nonnull void (^)(void))blockToExecute
    source:(nonnull NSString *)source
{
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    BOOL canExecuteTask = [self executeAsyncWithBlock:^{
        blockToExecute();
        dispatch_semaphore_signal(semaphore);
    } source:source];

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
