//
//  ADJClientSubscriptionsController.m
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientSubscriptionsController.h"

@import UIKit;

@interface ADJClientSubscriptionsController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJThreadController *threadControllerWeak;
@property (nullable, readonly, weak, nonatomic) id<ADJClientReturnExecutor> clientReturnExecutorWeak;
@property (nullable, readonly, strong, nonatomic) id<ADJAdjustAttributionSubscriber> adjustAttributionSubscriber;
@property (nullable, readonly, strong, nonatomic) id<ADJAdjustLogSubscriber> adjustLogSubscriber;
@property (readonly, assign, nonatomic) BOOL doNotOpenDeferredDeeplink;

#pragma mark - Internal variables

@end

@implementation ADJClientSubscriptionsController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             threadController:(nonnull ADJThreadController *)threadController
                         clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
                  adjustAttributionSubscriber:(nullable id<ADJAdjustAttributionSubscriber>)adjustAttributionSubscriber
                          adjustLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustLogSubscriber
                    doNotOpenDeferredDeeplink:(BOOL)doNotOpenDeferredDeeplink {
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
             attributionStatus:(nonnull NSString *)attributionStatus {
    ADJAdjustAttribution *_Nullable adjustAttribution =
    attributionData != nil ? [attributionData toAdjustAttribution] : nil;

    if ([attributionStatus isEqualToString:ADJAttributionStatusRead]) {
        if (adjustAttribution == nil) {
            [self.logger error:@"Unexpected nil attribution with Read attribution status"];
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
            [self.logger error:@"Unexpected valid attribution data on %@ status",
             attributionStatus];
        } else {
            [self.logger debug:@"Cannot notify client on attribution with %@ status",
             attributionStatus];
        }
        return;
    }

    [self.logger error:@"Cannot notify client on valid attribution with unknown status %@",
     attributionStatus];
}

#pragma mark - ADJLogSubscriber
- (void)didLogWithMessage:(nonnull NSString *)logMessage
                   source:(nonnull NSString *)source
           adjustLogLevel:(nonnull NSString *)adjustLogLevel {
    if (self.adjustLogSubscriber == nil) {
        return;
    }

    id<ADJClientReturnExecutor> clientReturnExecutor = self.clientReturnExecutorWeak;
    if (clientReturnExecutor == nil) {
        [self.logger error:@"Cannot publish adjust log message"
         " without reference to client return executor"];
        return;
    }

    [clientReturnExecutor executeClientReturnWithBlock:^{
        [ADJAdjustLogMessageData generateFullLogWithMessage:logMessage
                                                     source:source
                                            messageLogLevel:adjustLogLevel];
    }];
}

- (void)didLogMessagesPreInitWithArray:(nonnull NSArray<ADJAdjustLogMessageData *> *)preInitLogMessageArray {
    id<ADJAdjustLogSubscriber> localAdjustLogSubscriber = self.adjustLogSubscriber;
    if (localAdjustLogSubscriber == nil) {
        return;
    }

    id<ADJClientReturnExecutor> clientReturnExecutor = self.clientReturnExecutorWeak;
    if (clientReturnExecutor == nil) {
        [self.logger error:@"Cannot publish adjust pre init log message"
         " without reference to client return executor"];
        return;
    }

    [clientReturnExecutor executeClientReturnWithBlock:^{
        [localAdjustLogSubscriber didLogMessagesPreInitWithArray:preInitLogMessageArray];
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
        [self.logger error:@"Cannot publish read adjust attribution"
         " without reference to client return executor"];
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
        [self.logger error:@"Cannot publish changed adjust attribution"
         " without reference to client return executor"];
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
        [self.logger error:@"Cannot open deferred deeplink on main thread"
         " without reference to thread controller"];
        return;
    }

    NSURL *_Nullable deferredDeeplinkUrl = [NSURL URLWithString:deferredDeeplink.stringValue];

    if (deferredDeeplinkUrl == nil) {
        [self.logger info:@"Could not parse deferred deeplink NSURL: %@", deferredDeeplink];
        return;
    }

    UIApplication *sharedApplication = UIApplication.sharedApplication;
    if (sharedApplication == nil) {
        [self.logger debug:@"Could not obtain the shared application"];
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

    [self.logger error:
     @"Could not find selector in shared application to open deferred deeplink"];
#endif
}

+ (void)openDeferredDeeplinkWithUrl:(nonnull NSURL *)deferredDeeplinkUrl
                  sharedApplication:(nonnull UIApplication *)sharedApplication
                             logger:(nullable ADJLogger *)logger
         openUrlSelectorWithOptions:(nonnull SEL)openUrlSelectorWithOptions {
    NSMethodSignature *openUrlMethodSignatureWithOptions =
    [sharedApplication
     methodSignatureForSelector:openUrlSelectorWithOptions];
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
            [logger debug:@"Deferrerd deeplink open wih options"];
        } else {
            [logger error:@"Unable to open deferrerd deeplink with options"];
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
      openUrlSelectorWithoutOptions:(nonnull SEL)openUrlSelectorWithoutOptions {
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
        [logger debug:@"Deferrerd deeplink open wihout options"];
    } else {
        [logger error:@"Unable to open deferrerd deeplink without options"];
    }
}

@end

