//
//  ADJLogController.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLogController.h"

#import "ADJConsoleLogger.h"

#pragma mark Private class
@implementation ADJLogPublisher @end

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJLogPublisher *logPublisher;
 */
@interface ADJLogController()
#pragma mark - Injected dependencies
@property (nullable, readwrite, weak, nonatomic) ADJSingleThreadExecutor *commonExecutorWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) NSMutableArray<ADJLogMessageData *> *logMessageDataArray;
@property (nonnull, readonly, strong, nonatomic) ADJConsoleLogger *consoleLogger;
@property (readwrite, assign, nonatomic) BOOL canPublish;
@property (nonnull, readonly, strong, nonatomic) ADJInstanceIdData *instanceId;
@end

@implementation ADJLogController
#pragma mark Instantiation
- (nonnull instancetype)initWithSdkConfigData:(nonnull ADJSdkConfigData *)sdkConfigData
                          publisherController:(nonnull ADJPublisherController *)publisherController
                                   instanceId:(nonnull ADJInstanceIdData *)instanceId
{
    self = [super init];

    _instanceId = instanceId;

    _logPublisher = [[ADJLogPublisher alloc] initWithSubscriberProtocol:@protocol(ADJLogSubscriber)
                                                             controller:publisherController];

    _logMessageDataArray = [NSMutableArray array];
    
    _consoleLogger = [[ADJConsoleLogger alloc] initWithSdkConfigData:sdkConfigData];
    
    _canPublish = NO;
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (void)injectDependeciesWithCommonExecutor:(nonnull ADJSingleThreadExecutor *)commonExecutor {
    self.commonExecutorWeak = commonExecutor;
}

#pragma mark - ADJLogCollector
- (void)collectLogMessage:(nonnull ADJLogMessageData *)logMessageData {
    ADJSingleThreadExecutor *_Nullable commonExecutor = self.commonExecutorWeak;
    if (commonExecutor == nil) {
        return;
    }
    
    __typeof(self) __weak weakSelf = self;
    [commonExecutor executeInSequenceSkippingTraceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf.consoleLogger didLogMessage:logMessageData];

        if (strongSelf.canPublish) {
            [strongSelf.logPublisher notifySubscribersWithSubscriberBlock:
             ^(id<ADJLogSubscriber> _Nonnull subscriber)
             {
                [subscriber didLogMessage:logMessageData];
            }];
        } else {
            [strongSelf.logMessageDataArray addObject:logMessageData];
        }
    }];
}

#pragma mark - ADJLoggerFactory
- (nonnull ADJLogger *)createLoggerWithSource:(nonnull NSString *)source {
    return [[ADJLogger alloc] initWithSource:source
                                logCollector:self];
}

#pragma mark - ADJSdkInitStateSubscriber
- (void)ccOnSdkInitWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData {
    ADJSingleThreadExecutor *_Nullable commonExecutor = self.commonExecutorWeak;
    if (commonExecutor == nil) {
        return;
    }
    
    __typeof(self) __weak weakSelf = self;
    [commonExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf.consoleLogger didSdkInitWithIsSandboxEnvironment:clientConfigData.isSandboxEnvironmentOrElseProduction
                                                            doLogAll:clientConfigData.doLogAll
                                                         doNotLogAny:clientConfigData.doNotLogAny];
    } source:@"sdk init"];
}

#pragma mark - ADJPublishingGateSubscriber
- (void)ccAllowedToPublishNotifications {
    ADJSingleThreadExecutor *_Nullable commonExecutor = self.commonExecutorWeak;
    if (commonExecutor == nil) {
        return;
    }
    
    __typeof(self) __weak weakSelf = self;
    [commonExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        strongSelf.canPublish = YES;
        
        NSArray<ADJLogMessageData *> *_Nonnull preInitLogMessageArray =
            [strongSelf.logMessageDataArray copy];
        
        [strongSelf.logPublisher notifySubscribersWithSubscriberBlock:
         ^(id<ADJLogSubscriber> _Nonnull subscriber)
         {
            [subscriber didLogMessagesPreInitWithArray:preInitLogMessageArray];
        }];
        
        // can flush memory stored logs
        [strongSelf.logMessageDataArray removeAllObjects];
    } source:@"allowed to publish notifications"];
}

@end
