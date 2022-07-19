//
//  ADJSingleThreadExecutor.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJUtilSys.h"

#pragma mark Fields
@interface ADJSingleThreadExecutor ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) id<ADJThreadPool> threadPoolWeak;
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) NSMutableArray *blockQueue;
@property (readwrite, assign, nonatomic) BOOL isThreadExecuting;
@property (readwrite, assign, nonatomic) BOOL hasFinalized;

@end

@implementation ADJSingleThreadExecutor
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sourceDescription:(nonnull NSString *)sourceDescription
                                   threadPool:(nonnull id<ADJThreadPool>)threadPool
{
    self = [super initWithLoggerFactory:loggerFactory
                                 source:[NSString stringWithFormat:@"%@-SingleThreadExecutor",
                                         sourceDescription]];
    _threadPoolWeak = threadPool;

    _blockQueue = [NSMutableArray array];

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
    if (self.hasFinalized) {
        return NO;
    }

    id<ADJThreadPool> _Nullable threadPool = self.threadPoolWeak;
    if (threadPool == nil) {
        return NO;
    }

    __typeof(self) __weak weakSelf = self;
    return [threadPool scheduleAsyncWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf executeInSequenceWithBlock:blockToSchedule];
    } delayTimeMilli:delayTimeMilli];
}

- (BOOL)executeInSequenceWithBlock:(nonnull void (^)(void))blockToExecute {
    if (self.hasFinalized) {
        return NO;
    }

    id<ADJThreadPool> _Nullable threadPool = self.threadPoolWeak;
    if (threadPool == nil) {
        return NO;
    }

    @synchronized (self.blockQueue) {
        if (self.isThreadExecuting) {
            [self.blockQueue addObject:blockToExecute];
            return YES;
        }
        self.isThreadExecuting = YES;

        __typeof(self) __weak weakSelf = self;
        return [threadPool executeAsyncWithBlock:^{
            // run the first given task
            blockToExecute();

            __typeof(weakSelf) __strong strongSelf = weakSelf;
            if (strongSelf == nil) { return; }

            [strongSelf executeQueuedBlocks];
        }];
    }
}

#pragma mark - ADJTeardownFinalizer
- (void)finalizeAtTeardown {
    if (self.hasFinalized) {
        return;
    }
    self.hasFinalized = YES;

    /* without removing remaining blocks allows to finish queued tasks
    @synchronized (self.blockQueue) {
        [self.blockQueue removeAllObjects];
    }
     */
}

#pragma mark - NSObject
- (void)dealloc {
    [self finalizeAtTeardown];
}

#pragma mark Internal Methods
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

@end
