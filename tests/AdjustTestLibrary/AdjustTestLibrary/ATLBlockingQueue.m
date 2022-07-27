//
//  ATLBlockingQueue.m
//  AdjustTestLibrary
//
//  Created by Pedro on 11.01.18.
//  Copyright © 2018 adjust. All rights reserved.
//  Adapted from https://github.com/adamk77/MKBlockingQueue/blob/master/MKBlockingQueue/MKBlockingQueue.m
//

#import "ATLBlockingQueue.h"

@interface ATLBlockingQueue()

@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, strong) NSCondition *lock;
@property (nonatomic, strong) NSOperationQueue* operationQueue;

@end

@implementation ATLBlockingQueue

- (id)init
{
    self = [super init];
    if (self)
    {
        self.queue = [[NSMutableArray alloc] init];
        self.lock = [[NSCondition alloc] init];
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self.operationQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (void)enqueue:(id)object
{
    NSCondition *localLock = self.lock;
    NSMutableArray *localQueue = self.queue;
    if (localLock == nil || localQueue == nil) {
        return;
    }

    [localLock lock];
    [localQueue addObject:object];
    [localLock signal];
    [localLock unlock];
}

- (id)dequeue
{
    __block id object;
    __typeof(self) __weak weakSelf = self;
    [ATLUtil addOperationAfterLast:self.operationQueue blockWithOperation:^(NSBlockOperation * operation) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        NSCondition *localLock = strongSelf.lock;
        NSMutableArray *localQueue = strongSelf.queue;

        if (localLock == nil || localQueue == nil) {
            return;
        }

        [localLock lock];
        while (localQueue.count == 0)
        {
            if (operation.cancelled) {
                [localLock unlock];
                return;
            }
            [localLock wait];
        }
        if (operation.cancelled) {
            [localLock unlock];
            return;
        }
        if (localQueue.count > 0) {
            object = [localQueue objectAtIndex:0];
            [localQueue removeObjectAtIndex:0];
        }
        [localLock unlock];
    }];
    [self.operationQueue waitUntilAllOperationsAreFinished];

    return object;
}

- (void)teardown {
    NSCondition *localLock = self.lock;
    NSMutableArray *localQueue = self.queue;
    NSOperationQueue *localOperationQueue = self.operationQueue;

    if (localLock == nil) {
        return;
    }
    self.lock = nil;
    self.queue = nil;
    self.operationQueue = nil;

    [localLock lock];
    if (localQueue != nil) {
        [localQueue removeAllObjects];
    }
    if (localOperationQueue != nil) {
        [localOperationQueue cancelAllOperations];
    }
    [localLock broadcast];
    [localLock unlock];
}

@end
