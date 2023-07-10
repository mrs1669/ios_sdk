//
//  ADJClientSubscriptionsController.m
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientSubscriptionsController.h"

#import "ADJAdjustLogMessageData.h"
#import "ADJConsoleLogger.h"
#import "ADJUtilF.h"

#import <UIKit/UIKit.h>

@interface ADJClientSubscriptionsController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, strong, nonatomic) ADJThreadController *threadController;
@property (nonnull, readonly, strong, nonatomic)
    ADJAdidStateStorage *adidStateStorage;
@property (nonnull, readonly, strong, nonatomic)
    ADJAttributionStateStorage *attributionStateStorage;
@property (nullable, readonly, strong, nonatomic) id<ADJClientReturnExecutor> clientReturnExecutor;
@property (nullable, readonly, strong, nonatomic)
    id<ADJAdjustIdentifierSubscriber> adjustIdentifierSubscriber;
@property (nullable, readonly, strong, nonatomic)
    id<ADJAdjustAttributionSubscriber> adjustAttributionSubscriber;
@property (nullable, readonly, strong, nonatomic) id<ADJAdjustLogSubscriber> adjustLogSubscriber;
@property (nullable, readonly, strong, nonatomic)
    NSDictionary<NSString *, id<ADJInternalCallback>> *internalConfigSubscriptions;
@property (readonly, assign, nonatomic) BOOL doNotOpenDeferredDeeplink;

#pragma mark - Internal variables
@property (nullable, readwrite, strong, nonatomic) ADJAttributionData *cachedAttributionData;

@end

@implementation ADJClientSubscriptionsController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadController:(nonnull ADJThreadController *)threadController
    adidStateStorage:(nonnull ADJAdidStateStorage *)adidStateStorage
    attributionStateStorage:(nonnull ADJAttributionStateStorage *)attributionStateStorage
    clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
    adjustIdentifierSubscriber:
        (nonnull id<ADJAdjustIdentifierSubscriber>)adjustIdentifierSubscriber
    adjustAttributionSubscriber:
        (nullable id<ADJAdjustAttributionSubscriber>)adjustAttributionSubscriber
    adjustLogSubscriber:(nullable id<ADJAdjustLogSubscriber>)adjustLogSubscriber
    internalConfigSubscriptions:
        (nullable NSDictionary<NSString *, id<ADJInternalCallback>> *)internalConfigSubscriptions
    doNotOpenDeferredDeeplink:(BOOL)doNotOpenDeferredDeeplink;
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"ClientSubscriptionsController"];
    _threadController = threadController;
    _adidStateStorage = adidStateStorage;
    _attributionStateStorage = attributionStateStorage;
    _clientReturnExecutor = clientReturnExecutor;
    _adjustIdentifierSubscriber = adjustIdentifierSubscriber;
    _adjustAttributionSubscriber = adjustAttributionSubscriber;
    _adjustLogSubscriber = adjustLogSubscriber;
    _internalConfigSubscriptions = internalConfigSubscriptions;
    _doNotOpenDeferredDeeplink = doNotOpenDeferredDeeplink;

    _cachedAttributionData = nil;

    return self;
}

#pragma mark Public API
#pragma mark - ADJSdkInitSubscriber
- (void)ccOnSdkInitWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData {
    [self ccNotifyClientOnSdkInitForAdid];
    [self ccNotifyClientOnSdkInitForAttribution];
}

#pragma mark - ADJAdidSubscriber
- (void)onAdidUpdateWithValue:(nonnull ADJNonEmptyString *)updatedAdid {
    __block id<ADJAdjustIdentifierSubscriber> localAdjustIdentifierSubscriber =
        self.adjustIdentifierSubscriber;

    if (localAdjustIdentifierSubscriber == nil) {
        return;
    }

    [self.logger debugDev:@"Notifying client on updated adid"];

    [self.clientReturnExecutor executeClientReturnWithBlock:^{
        [localAdjustIdentifierSubscriber didUpdateWithAdjustIdentifier:updatedAdid.stringValue];
    }];
}

#pragma mark - ADJAttributionSubscriber
// It is assumed that this event cannot occur before 'SdkInitSubscriber.ccOnSdkInit'
//  If it should be possible, then it should be replaced for something that can guarantee it,
//  like SubscribingGateSubscriber.ccAllowedToReceiveEvents'
- (void)attributionWithStateData:(nonnull ADJAttributionStateData *)attributionStateData {
    // we're only notifying to the client with non null updates of the attribution data
    if (attributionStateData.attributionData == nil) {
        return;
    }

    if ([attributionStateData.attributionData isEqual:self.cachedAttributionData]) {
        return;
    }

    self.cachedAttributionData = attributionStateData.attributionData;

    [self notifyClientWithUpdatedAttribution:attributionStateData.attributionData];

    [self openDeferredDeeplink:attributionStateData.attributionData.deeplink];
}

#pragma mark - ADJLogSubscriber
- (void)didLogMessage:(nonnull ADJLogMessageData *)logMessageData {
    id<ADJAdjustLogSubscriber> localAdjustLogSubscriber = self.adjustLogSubscriber;
    if (localAdjustLogSubscriber == nil) {
        return;
    }

    __block NSString *_Nonnull clientLogMessage =
        [ADJConsoleLogger clientCallbackFormatMessageWithLog:logMessageData.inputData];

    [self.clientReturnExecutor executeClientReturnWithBlock:^{
        [localAdjustLogSubscriber didLogWithMessage:clientLogMessage
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

    NSMutableArray<ADJAdjustLogMessageData *> *_Nonnull adjustLogArray =
        [[NSMutableArray alloc] initWithCapacity:preInitLogMessageArray.count];
    
    for (ADJLogMessageData *_Nonnull logData in preInitLogMessageArray) {
        [adjustLogArray addObject:[[ADJAdjustLogMessageData alloc]
                                   initWithLogMessage:@""
                                   messageLogLevel:logData.inputData.level]];
    }

    [self.clientReturnExecutor executeClientReturnWithBlock:^{
        [localAdjustLogSubscriber didLogMessagesPreInitWithArray:adjustLogArray];
    }];
}

#pragma mark Internal Methods
- (void)ccNotifyClientOnSdkInitForAdid {
    __block id<ADJAdjustIdentifierSubscriber> localAdjustIdentifierSubscriber =
        self.adjustIdentifierSubscriber;

    if (localAdjustIdentifierSubscriber == nil) {
        return;
    }

    ADJAdidStateData *_Nonnull adidStateData = [self.adidStateStorage readOnlyStoredDataValue];

    if (adidStateData.adid == nil) {
        [self.logger debugDev:@"Not notifying client on init without read adid"];
        return;
    }

    [self.logger debugDev:@"Notifying client on init with read adid"];

    [self.clientReturnExecutor executeClientReturnWithBlock:^{
        [localAdjustIdentifierSubscriber
         didReadWithAdjustIdentifier:adidStateData.adid.stringValue];
    }];
}

- (void)ccNotifyClientOnSdkInitForAttribution {
    __block id<ADJAdjustAttributionSubscriber> localAdjustAttributionSubscriber =
        self.adjustAttributionSubscriber;

    __block id<ADJInternalCallback> _Nullable internalAttributionCallback =
        self.internalConfigSubscriptions == nil ? nil :
        [self.internalConfigSubscriptions objectForKey:ADJInternalAttributionSubscriberV5000Key];

    if (localAdjustAttributionSubscriber == nil && internalAttributionCallback == nil) {
        return;
    }

    ADJAttributionStateData *_Nonnull attributionStateData =
        [self.attributionStateStorage readOnlyStoredDataValue];
    ADJAttributionData *_Nullable attributionData = attributionStateData.attributionData;

    if (attributionData == nil) {
        [self.logger debugDev:@"Not notifying client on init without read attribution"];
        return;
    }

    [self.logger debugDev:@"Notifying client on init with read attribution"];
    self.cachedAttributionData = attributionData;

    if (localAdjustAttributionSubscriber != nil) {
        __block ADJAdjustAttribution *_Nonnull adjustAttribution =
            [attributionData toAdjustAttribution];

        [self.clientReturnExecutor executeClientReturnWithBlock:^{
            [localAdjustAttributionSubscriber didReadWithAdjustAttribution:adjustAttribution];
        }];
    }

    if (internalAttributionCallback != nil) {
        ADJOptionalFails<NSDictionary<NSString *, id> *> *_Nonnull callbackDataOptFails =
            [attributionData
             buildInternalCallbackDataWithMethodName:ADJReadAttributionMethodName];
        for (ADJResultFail *_Nonnull optFail in callbackDataOptFails.optionalFails) {
            [self.logger debugDev:@"Issue while building read attribution internal callback"
                       resultFail:optFail
                        issueType:ADJIssueNonNativeIntegration];
        }

        __block NSDictionary<NSString *, id> *_Nonnull callbackData = callbackDataOptFails.value;
        [self.clientReturnExecutor executeClientReturnWithBlock:^{
            [internalAttributionCallback didInternalCallbackWithData:callbackData];
        }];
    }
}

- (void)notifyClientWithUpdatedAttribution:(nonnull ADJAttributionData *)attributionData {
    __block id<ADJAdjustAttributionSubscriber> localAdjustAttributionSubscriber =
        self.adjustAttributionSubscriber;

    __block id<ADJInternalCallback> _Nullable internalAttributionCallback =
        self.internalConfigSubscriptions == nil ? nil :
        [self.internalConfigSubscriptions objectForKey:ADJInternalAttributionSubscriberV5000Key];

    if (localAdjustAttributionSubscriber == nil && internalAttributionCallback == nil) {
        return;
    }

    [self.logger debugDev:@"Notifying client on updated attribution"];

    if (localAdjustAttributionSubscriber != nil) {
        __block ADJAdjustAttribution *_Nonnull adjustAttribution =
            [attributionData toAdjustAttribution];

        [self.clientReturnExecutor executeClientReturnWithBlock:^{
            [localAdjustAttributionSubscriber didUpdateWithAdjustAttribution:adjustAttribution];
        }];
    }

    if (internalAttributionCallback != nil) {
        ADJOptionalFails<NSDictionary<NSString *, id> *> *_Nonnull callbackDataOptFails =
            [attributionData
             buildInternalCallbackDataWithMethodName:ADJUpdatedAttributionMethodName];
        for (ADJResultFail *_Nonnull optFail in callbackDataOptFails.optionalFails) {
            [self.logger debugDev:@"Issue while building updated attribution internal callback"
                       resultFail:optFail
                        issueType:ADJIssueNonNativeIntegration];
        }

        __block NSDictionary<NSString *, id> *_Nonnull callbackData = callbackDataOptFails.value;
        [self.clientReturnExecutor executeClientReturnWithBlock:^{
            [internalAttributionCallback didInternalCallbackWithData:callbackData];
        }];
    }
}

- (void)openDeferredDeeplink:(nullable ADJNonEmptyString *)deferredDeeplink {
#if defined(ADJUST_IM)
    return;
#else
    if (self.doNotOpenDeferredDeeplink) {
        return;
    }

    if (deferredDeeplink == nil) {
        return;
    }

    NSURL *_Nullable deferredDeeplinkUrl = [NSURL URLWithString:deferredDeeplink.stringValue];

    if (deferredDeeplinkUrl == nil) {
        [self.logger infoClient:@"Could not parse deferred deeplink as NSURL"
                            key:@"deferred deeplink"
                    stringValue:deferredDeeplink.stringValue];
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
        [self.threadController executeInMainThreadWithBlock:^{
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
        [self.threadController executeInMainThreadWithBlock:^{
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

