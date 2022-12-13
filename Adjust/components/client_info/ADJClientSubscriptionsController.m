//
//  ADJClientSubscriptionsController.m
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientSubscriptionsController.h"

#import "ADJAdjustLogMessageData.h"

@import UIKit;

@interface ADJClientSubscriptionsController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJThreadController *threadControllerWeak;
@property (nullable, readonly, weak, nonatomic)
    id<ADJClientReturnExecutor> clientReturnExecutorWeak;
@property (nullable, readonly, strong, nonatomic)
    id<ADJAdjustAttributionSubscriber> adjustAttributionSubscriber;
@property (nullable, readonly, strong, nonatomic) id<ADJAdjustLogSubscriber> adjustLogSubscriber;
@property (readonly, assign, nonatomic) BOOL doNotOpenDeferredDeeplink;

#pragma mark - Internal variables

@end

@implementation ADJClientSubscriptionsController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadController:(nonnull ADJThreadController *)threadController
    clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
    adjustAttributionSubscriber:
        (nullable id<ADJAdjustAttributionSubscriber>)adjustAttributionSubscriber
    adjustLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustLogSubscriber
    doNotOpenDeferredDeeplink:(BOOL)doNotOpenDeferredDeeplink
{
    self = [super initWithLoggerFactory:loggerFactory source:@"ClientSubscriptionsController"];
    _threadControllerWeak = threadController;
    _clientReturnExecutorWeak = clientReturnExecutor;
    _adjustAttributionSubscriber = adjustAttributionSubscriber;
    _adjustLogSubscriber = adjustLogSubscriber;
    _doNotOpenDeferredDeeplink = doNotOpenDeferredDeeplink;

    return self;
}

#pragma mark Public API
#pragma mark - ADJAttributionSubscriber
- (void)didAttributionWithData:(nullable ADJAttributionData *)attributionData
             attributionStatus:(nonnull NSString *)attributionStatus
{
    ADJAdjustAttribution *_Nullable adjustAttribution =
        attributionData != nil ? [attributionData toAdjustAttribution] : nil;

    if ([attributionStatus isEqualToString:ADJAttributionStatusRead]) {
        if (adjustAttribution == nil) {
            [self.logger debugDev:@"Unexpected nil attribution with Read attribution status"
                        issueType:ADJIssueLogicError];
            return;
        }
        [self attributionReadWithAdjustData:adjustAttribution];
        return;
    }

    if ([attributionStatus isEqualToString:ADJAttributionStatusCreated]
        || [attributionStatus isEqualToString:ADJAttributionStatusUpdated])
    {
        [self attributionChangedWithAdjustData:adjustAttribution];

        [self attributionChangedWithDeferredDeeplink:
         attributionData != nil ? attributionData.deeplink : nil];

        return;
    }

    if ([attributionStatus isEqualToString:ADJAttributionStatusNotAvailableFromBackend]
        || [attributionStatus isEqualToString:ADJAttributionStatusWaiting])
    {
        if (attributionData != nil) {
            [self.logger debugDev:@"Unexpected valid attribution data"
                              key:@"status"
                            value:attributionStatus
                        issueType:ADJIssueLogicError];
        } else {
            [self.logger debugDev:@"Cannot notify client on attribution due to its status"
                              key:@"status"
                            value:attributionStatus];
        }
        return;
    }

    [self.logger debugDev:@"Cannot notify client on valid attribution with unknown status"
                      key:@"statue"
                    value:attributionStatus
                issueType:ADJIssueUnexpectedInput];
}

#pragma mark - ADJLogSubscriber
- (void)didLogMessage:(nonnull ADJLogMessageData *)logMessageData {
    id<ADJAdjustLogSubscriber> localAdjustLogSubscriber = self.adjustLogSubscriber;
    if (localAdjustLogSubscriber == nil) {
        return;
    }

    id<ADJClientReturnExecutor> clientReturnExecutor = self.clientReturnExecutorWeak;
    if (clientReturnExecutor == nil) {
        /* Must not use the "normal" logging downstream of the log collector
            to prevent becoming in a loop
        [self.logger debugDev:
         @"Cannot publish adjust log message without reference to client return executor"
                    issueType:ADJIssueWeakReference];
         */
        return;
    }

    [clientReturnExecutor executeClientReturnWithBlock:^{
        [localAdjustLogSubscriber didLogWithMessage:logMessageData.inputData.message
                                           logLevel:logMessageData.inputData.level];
    }];
}

- (void)didLogMessagesPreInitWithArray:
    (nonnull NSArray<ADJLogMessageData *> *)preInitLogMessageArray
{
    id<ADJAdjustLogSubscriber> localAdjustLogSubscriber = self.adjustLogSubscriber;
    if (localAdjustLogSubscriber == nil) {
        return;
    }

    id<ADJClientReturnExecutor> clientReturnExecutor = self.clientReturnExecutorWeak;
    if (clientReturnExecutor == nil) {
        [self.logger debugDev:
         @"Cannot publish adjust pre init log message without reference to client return executor"
                    issueType:ADJIssueWeakReference];
        return;
    }
    
    NSMutableArray<ADJAdjustLogMessageData *> *_Nonnull adjustLogArray =
        [[NSMutableArray alloc] initWithCapacity:preInitLogMessageArray.count];
    
    for (ADJLogMessageData *_Nonnull logData in preInitLogMessageArray) {
        [adjustLogArray addObject:[[ADJAdjustLogMessageData alloc]
                                   initWithLogMessage:@""
                                   messageLogLevel:logData.inputData.level]];
    }

    [clientReturnExecutor executeClientReturnWithBlock:^{
        [localAdjustLogSubscriber didLogMessagesPreInitWithArray:adjustLogArray];
    }];
}

#pragma mark - Subscriptions
- (void)ccSubscribeToPublishersWithAttributionPublisher:(nonnull ADJAttributionPublisher *)attributionPublisher
                                           logPublisher:(nonnull ADJLogPublisher *)logPublisher {
    [attributionPublisher addSubscriber:self];
    if (self.adjustLogSubscriber != nil) {
        [logPublisher addSubscriber:self];
    }
}

#pragma mark Internal Methods
- (void)attributionReadWithAdjustData:(nonnull ADJAdjustAttribution *)adjustAttribution {
    id<ADJAdjustAttributionSubscriber> localAdjustAttributionSubscriber =
        self.adjustAttributionSubscriber;

    if (localAdjustAttributionSubscriber == nil) {
        return;
    }

    id<ADJClientReturnExecutor> clientReturnExecutor = self.clientReturnExecutorWeak;
    if (clientReturnExecutor == nil) {
        [self.logger debugDev:
         @"Cannot publish read adjust attribution without reference to client return executor"
                    issueType:ADJIssueWeakReference];
        return;
    }

    [clientReturnExecutor executeClientReturnWithBlock:^{
        [localAdjustAttributionSubscriber didReadWithAdjustAttribution:adjustAttribution];
    }];
}

- (void)attributionChangedWithAdjustData:(nullable ADJAdjustAttribution *)adjustAttribution {
    id<ADJAdjustAttributionSubscriber> localAdjustAttributionSubscriber =
    self.adjustAttributionSubscriber;

    if (localAdjustAttributionSubscriber == nil) {
        return;
    }

    id<ADJClientReturnExecutor> clientReturnExecutor = self.clientReturnExecutorWeak;
    if (clientReturnExecutor == nil) {
        [self.logger debugDev:
         @"Cannot publish changed adjust attribution without reference to client return executor"
                    issueType:ADJIssueWeakReference];
        return;
    }

    [clientReturnExecutor executeClientReturnWithBlock:^{
        [localAdjustAttributionSubscriber didChangeWithAdjustAttribution:adjustAttribution];
    }];
}

- (void)attributionChangedWithDeferredDeeplink:(nullable ADJNonEmptyString *)deferredDeeplink {
#if defined(ADJUST_IM)
    return;
#else
    if (self.doNotOpenDeferredDeeplink) {
        return;
    }

    if (deferredDeeplink == nil) {
        return;
    }

    ADJThreadController *_Nullable threadController = self.threadControllerWeak;
    if (threadController == nil) {
        [self.logger debugDev:
         @"Cannot open deferred deeplink on main thread without reference to thread controller"
                    issueType:ADJIssueWeakReference];
        return;
    }

    NSURL *_Nullable deferredDeeplinkUrl = [NSURL URLWithString:deferredDeeplink.stringValue];

    if (deferredDeeplinkUrl == nil) {
        [self.logger infoClient:@"Could not parse deferred deeplink as NSURL"
                            key:@"deferred deeplink"
                          value:deferredDeeplink.stringValue];
        return;
    }

    UIApplication *sharedApplication = UIApplication.sharedApplication;
    if (sharedApplication == nil) {
        [self.logger debugDev:@"Could not obtain the shared application"
                    issueType:ADJIssueExternalApi];
        return;
    }

    ADJLogger *__weak loggerWeak = self.logger;

    SEL openUrlSelectorWithOptions = @selector(openURL:options:completionHandler:);
    if ([sharedApplication respondsToSelector:openUrlSelectorWithOptions]) {
        [threadController executeInMainThreadWithBlock:^{
            ADJLogger *__strong logger = loggerWeak;

            [ADJClientSubscriptionsController
             openDeferredDeeplinkWithUrl:deferredDeeplinkUrl
             sharedApplication:sharedApplication
             logger:logger
             openUrlSelectorWithOptions:openUrlSelectorWithOptions];
        }];
        return;
    }

    SEL openUrlSelectorWithoutOptions = @selector(openURL:);
    if ([sharedApplication respondsToSelector:openUrlSelectorWithoutOptions]) {
        [threadController executeInMainThreadWithBlock:^{
            ADJLogger *__strong logger = loggerWeak;

            [ADJClientSubscriptionsController
             openDeferredDeeplinkWithUrl:deferredDeeplinkUrl
             sharedApplication:sharedApplication
             logger:logger
             openUrlSelectorWithoutOptions:openUrlSelectorWithoutOptions];
        }];
        return;
    }

    [self.logger debugDev:
     @"Could not find selector in shared application to open deferred deeplink"
                issueType:ADJIssueExternalApi];
#endif
}

+ (void)openDeferredDeeplinkWithUrl:(nonnull NSURL *)deferredDeeplinkUrl
                  sharedApplication:(nonnull UIApplication *)sharedApplication
                             logger:(nullable ADJLogger *)logger
         openUrlSelectorWithOptions:(nonnull SEL)openUrlSelectorWithOptions
{
    NSMethodSignature *openUrlMethodSignatureWithOptions =
        [sharedApplication methodSignatureForSelector:openUrlSelectorWithOptions];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:openUrlMethodSignatureWithOptions];
    [invocation setSelector:openUrlSelectorWithOptions];
    [invocation setTarget:sharedApplication];

    NSDictionary *emptyDictionary = @{};
    void (^completion)(BOOL) = ^(BOOL success) {
        if (logger == nil) {
            return;
        }

        if (success) {
            [logger debugDev:@"Deferrerd deeplink open wih options"];
        } else {
            [logger debugDev:@"Unable to open deferrerd deeplink with options"
                   issueType:ADJIssueExternalApi];
        }
    };

    [invocation setArgument:&deferredDeeplinkUrl atIndex: 2];
    [invocation setArgument:&emptyDictionary atIndex: 3];
    [invocation setArgument:&completion atIndex: 4];
    [invocation invoke];
    /*
     [sharedApplication openURL:deferredDeeplinkUrl
     options:emptyDictionary
     completionHandler:completion];
     */
}

+ (void)openDeferredDeeplinkWithUrl:(nonnull NSURL *)deferredDeeplinkUrl
                  sharedApplication:(nonnull UIApplication *)sharedApplication
                             logger:(nullable ADJLogger *)logger
      openUrlSelectorWithoutOptions:(nonnull SEL)openUrlSelectorWithoutOptions
{
    IMP imp = [sharedApplication methodForSelector:openUrlSelectorWithoutOptions];

    BOOL (*func)(id, SEL, NSURL *) = (void *)imp;

    BOOL openURLResult =
        func(sharedApplication, openUrlSelectorWithoutOptions, deferredDeeplinkUrl);
    /*
     BOOL openURLResult = [sharedApplication openURL:deferredDeeplinkUrl];
     */

    if (logger == nil) {
        return;
    }

    if (openURLResult) {
        [logger debugDev:@"Deferrerd deeplink open wihout options"];
    } else {
        [logger debugDev:@"Unable to open deferrerd deeplink without options"
               issueType:ADJIssueExternalApi];
    }
}

@end

