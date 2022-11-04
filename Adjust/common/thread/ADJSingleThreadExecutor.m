//
//  ADJSingleThreadExecutor.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSingleThreadExecutor.h"
#import "ADJUtilSys.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) dispatch_queue_t dispachQueue;
 */

@interface ADJSingleThreadExecutor ()
#pragma mark - Injected dependencies
#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL isThreadExecuting;
@property (readwrite, assign, nonatomic) BOOL hasFinalized;

@end

@implementation ADJSingleThreadExecutor
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sourceDescription:(nonnull NSString *)sourceDescription
{
    self = [super initWithLoggerFactory:loggerFactory
                                 source:[NSString stringWithFormat:@"%@-SingleThreadExecutor",
                                         sourceDescription]];

    _dispachQueue = dispatch_queue_create(self.source.UTF8String, DISPATCH_QUEUE_SERIAL);

    _isThreadExecuting = NO;
    _hasFinalized = NO;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (BOOL)scheduleInSequenceWithBlock:(nonnull void (^)(void))blockToSchedule
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
         self.dispachQueue,
         blockToSchedule);

    return YES;
}

- (BOOL)executeInSequenceWithBlock:(nonnull void (^)(void))blockToExecute {
    if (self.hasFinalized) {
        return NO;
    }

    //__typeof(self) __weak weakSelf = self;
    dispatch_async(self.dispachQueue, ^{
        //__typeof(weakSelf) __strong strongSelf = weakSelf;
        //if (strongSelf != nil) { return; }

        blockToExecute();
    });

    return YES;
}

- (BOOL)executeAsyncWithBlock:(nonnull void (^)(void))blockToExecute {
    if (self.hasFinalized) {
        return NO;
    }

    dispatch_async(self.dispachQueue, blockToExecute);

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

#pragma mark - ADJTeardownFinalizer
- (void)finalizeAtTeardown {
    if (self.hasFinalized) {
        return;
    }
    self.hasFinalized = YES;
}

#pragma mark - NSObject
- (void)dealloc {
    [self finalizeAtTeardown];
}

#pragma mark Internal Methods
/*
 private void tryToRunI(@NonNull final RunnableWrap runnableWrap) {
     try {
         // not inside the skip local trace id check
         //  since .setNextLocalId() has the side effect of writing the thread local id
         @NonNull final NonNegativeLong runningThreadId =
                 LocalThreadController.setNextLocalIdAndReturnIt();

         if (! runnableWrap.skipTraceLocalId) {
             @NonNull final NonNegativeLong callerThreadId = runnableWrap.callerThreadId;

             logger.trace(callerThreadId, runningThreadId,
                     "Changing Thread local id from %s to %s in: %s",
                     callerThreadId, runningThreadId, runnableWrap.sourceDescription);
         }

         runnableWrap.run();
     } catch (@Nullable final Throwable throwable) {
         // catch exception here, instead of letting thread pool handle it, to have log of source
         logger.errorStackTrace(IssueType.THREADS_AND_LOCKS, throwable, "Execution failed");
     }
 }

- (void)executeQueuedBlocks {
    void (^nextBlockToExecute)(void);

    while (YES) {
        @synchronized (self.blockQueue) {
            // exit condition of while true loop, when no more tasks are left to run
            if (self.blockQueue.count == 0) {
                self.isThreadExecuting = NO;
                break;
            }
            // pop next task to be run
            nextBlockToExecute = [self.blockQueue objectAtIndex:0];
            [self.blockQueue removeObjectAtIndex:0];
        }

        // running of the next task outside of synchronized to not block it
        nextBlockToExecute();
    }
}
*/
@end
