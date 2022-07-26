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
@property (nonnull, readonly, strong, nonatomic)
NSMutableArray<ADJAdjustLogMessageData *> *logMessageDataArray;

@property (nonnull, readonly, strong, nonatomic) ADJConsoleLogger *consoleLogger;

@property (assign, readwrite, nonatomic) BOOL canPublish;
@end

@implementation ADJLogController
#pragma mark Instantiation
- (nonnull instancetype)init {
    self = [super init];
    
    _logPublisher = [[ADJLogPublisher alloc] init];
    
    _logMessageDataArray = [NSMutableArray array];
    
    _consoleLogger = [[ADJConsoleLogger alloc] init];
    
    _canPublish = NO;
    
    return self;
}

#pragma mark Public API
- (void)injectDependeciesWithCommonExecutor:(nonnull ADJSingleThreadExecutor *)commonExecutor {
    self.commonExecutorWeak = commonExecutor;
}

- (void)setEnvironmentToSandbox {
    [self.consoleLogger setEnvironmentToSandbox];
}

#pragma mark - ADJLogCollector
- (void)collectLogMessage:(nonnull NSString *)logMessage
                   source:(nonnull NSString *)source
          messageLogLevel:(nonnull NSString *)messageLogLevel {
    __typeof(self) __weak weakSelf = self;
    void (^_Nonnull publishLogMessageBlock)(void)  = ^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf.consoleLogger didLogMessage:logMessage
                                         source:source
                                messageLogLevel:messageLogLevel];
        
        if (strongSelf.canPublish) {
            [strongSelf.logPublisher notifySubscribersWithSubscriberBlock:
             ^(id<ADJLogSubscriber> _Nonnull subscriber)
             {
                [subscriber didLogWithMessage:logMessage
                                       source:source
                               adjustLogLevel:messageLogLevel];
            }];
        } else {
            [strongSelf.logMessageDataArray addObject:
             [[ADJAdjustLogMessageData alloc]
              initWithLogMessage:[NSString stringWithFormat:@"[PreInit]%@", logMessage]
              source:source
              messageLogLevel:messageLogLevel]];
        }
    };
    
    ADJSingleThreadExecutor *_Nullable commonExecutor = self.commonExecutorWeak;
    
    if (commonExecutor != nil) {
        [commonExecutor executeInSequenceWithBlock:publishLogMessageBlock];
    } else {
        publishLogMessageBlock();
    }
}

#pragma mark - ADJLoggerFactory
- (nonnull ADJLogger *)createLoggerWithSource:(nonnull NSString *)source {
    return [[ADJLogger alloc] initWithSource:source
                                logCollector:self];
}

#pragma mark - Subscriptions
- (void)ccSubscribeToPublishersWithSdkInitPublisher:(nonnull ADJSdkInitPublisher *)sdkInitPublisher
                            publishingGatePublisher:(nonnull ADJPublishingGatePublisher *)publishingGatePublisher {
    [sdkInitPublisher addSubscriber:self];
    [publishingGatePublisher addSubscriber:self];
}

#pragma mark - ADJSdkInitStateSubscriber
- (void)ccOnSdkInitWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData {
    __typeof(self) __weak weakSelf = self;
    void (^_Nonnull sdkInitBlock)(void)  = ^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf.consoleLogger
         didSdkInitWithIsSandboxEnvironment:
             clientConfigData.isSandboxEnvironmentOrElseProduction
         logLevel:clientConfigData.logLevel];
    };
    
    ADJSingleThreadExecutor *_Nullable commonExecutor = self.commonExecutorWeak;
    
    if (commonExecutor != nil) {
        [commonExecutor executeInSequenceWithBlock:sdkInitBlock];
    } else {
        sdkInitBlock();
    }
}

#pragma mark - ADJPublishingGateSubscriber
- (void)ccAllowedToPublishNotifications {
    __typeof(self) __weak weakSelf = self;
    void (^_Nonnull canPublish)(void)  = ^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        strongSelf.canPublish = YES;
        
        NSArray<ADJAdjustLogMessageData *> *_Nonnull preInitLogMessageArray =
        [strongSelf.logMessageDataArray copy];
        
        [strongSelf.logPublisher notifySubscribersWithSubscriberBlock:
         ^(id<ADJLogSubscriber> _Nonnull subscriber)
         {
            [subscriber didLogMessagesPreInitWithArray:preInitLogMessageArray];
        }];
        
        // can flush memory stored logs
        [strongSelf.logMessageDataArray removeAllObjects];
    };
    
    ADJSingleThreadExecutor *_Nullable commonExecutor = self.commonExecutorWeak;
    
    if (commonExecutor != nil) {
        [commonExecutor executeInSequenceWithBlock:canPublish];
    } else {
        canPublish();
    }
}

@end
