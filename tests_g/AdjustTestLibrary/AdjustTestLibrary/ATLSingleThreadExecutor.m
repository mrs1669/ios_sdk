//
//  ATLSingleThreadExecutor.m
//  AdjustTestLibrary
//
//  Created by Pedro S. on 23.07.21.
//  Copyright © 2021 adjust. All rights reserved.
//

#import "ATLSingleThreadExecutor.h"

@interface ATLSingleThreadExecutor ()

@property (nonnull, readonly, strong, nonatomic) NSMutableArray *blockQueue;
//@property (readwrite, assign, nonatomic) BOOL hasFinalized;
@property (readwrite, assign, nonatomic) BOOL isThreadExecuting;

@end

@implementation ATLSingleThreadExecutor {
    volatile BOOL _hasFinalized;
}

- (nonnull instancetype)init {
    self = [super init];

    _blockQueue = [NSMutableArray array];

    _isThreadExecuting = NO;
    _hasFinalized = NO;

    return self;
}

- (BOOL)executeInSequenceWithBlock:(nonnull void (^)(void))blockToExecute {
    if (_hasFinalized) {
        return NO;
    }

    @synchronized (self.blockQueue) {
        if (self.isThreadExecuting) {
            [self.blockQueue addObject:blockToExecute];
            return YES;
        }
        self.isThreadExecuting = YES;

        __typeof(self) __weak weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),^{
            __typeof(weakSelf) __strong strongSelf = weakSelf;
            if (strongSelf == nil) { return; }

            [strongSelf executeQueuedBlocks:blockToExecute];
        });
    }
    return YES;
}

- (void)executeQueuedBlocks:(nonnull void (^)(void))firstBlockToExecute {
    if (_hasFinalized) {
        return;
    }

    // run the first given task
    firstBlockToExecute();

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

- (void)dealloc {
    [self finalizeAtTeardown];
}

- (void)finalizeAtTeardown {
    if (_hasFinalized) {
        return;
    }
    _hasFinalized = YES;

    [self clearQueuedBlocks];
}

- (void)clearQueuedBlocks {
    @synchronized (self.blockQueue) {
        [self.blockQueue removeAllObjects];
    }
}

@end
