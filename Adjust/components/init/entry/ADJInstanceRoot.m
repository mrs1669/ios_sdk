//
//  ADJInstanceRoot.m
//  Adjust
//
//  Created by Genady Buchatsky on 04.11.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJInstanceRoot.h"
#import "ADJLogController.h"
#import "ADJThreadController.h"
#import "ADJSingleThreadExecutor.h"
#import "ADJLogger.h"
#import "ADJSdkConfigData.h"
#import "ADJPreSdkInitRootController.h"
#import "ADJPostSdkInitRootController.h"
#import "ADJPublishersRegistry.h"

@interface ADJInstanceRoot ()
@property (nullable, readonly, strong, nonatomic) NSString *instanceId;
@property (nonnull, readonly, strong, nonatomic) ADJLogController *logController;
@property (nonnull, readonly, strong, nonatomic) ADJThreadController *threadController;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *clientExecutor;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *commonExecutor;
@property (nonnull, readonly, strong, nonatomic) ADJLogger *adjustApiLogger;
@property (nullable, readwrite, strong, nonatomic) ADJPreSdkInitRootController *preSdkInitRootController;
@property (nullable, readwrite, strong, nonatomic) ADJPostSdkInitRootController *postSdkInitRootController;
@property (nonnull, readwrite, strong, nonatomic) ADJClock *clock;
@property (nonnull, readonly, strong, nonatomic) ADJSdkConfigData *sdkConfigData;
@property (nonnull, readwrite, strong, nonatomic) ADJPublishersRegistry *publishersRegistry;
@end

@implementation ADJInstanceRoot

- (nonnull instancetype)initWithConfigData:(nonnull ADJSdkConfigData *)configData
                                instanceId:(nonnull NSString *)instanceId {

    self = [super init];

    _instanceId = [instanceId copy];
    _clock = [[ADJClock alloc] init];
    _sdkConfigData = configData;

    // Publishers registry
    _publishersRegistry = [[ADJPublishersRegistry alloc] init];

    // Controllers
    _logController = [[ADJLogController alloc] initWithSdkConfigData:configData
                                                  publishersRegistry:_publishersRegistry
                                                          InstanceId:instanceId];

    _threadController = [[ADJThreadController alloc] initWithLoggerFactory:_logController];

    // Executors
    _clientExecutor = [_threadController createSingleThreadExecutorWithLoggerFactory:_logController
                                                                   sourceDescription:@"clientExecutor"];
    _commonExecutor = [_threadController createSingleThreadExecutorWithLoggerFactory:_logController
                                                                   sourceDescription:@"commonExecutor"];
    [_logController injectDependeciesWithCommonExecutor:_commonExecutor];

    // Loggers
    _adjustApiLogger = [_logController createLoggerWithSource:@"Adjust"];

    __typeof(self) __weak weakSelf = self;
    [_clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        id<ADJClientReturnExecutor> clentReturnExecutor =
        (strongSelf.sdkConfigData.clientReturnExecutorOverwrite) ? : strongSelf.threadController;

        strongSelf.preSdkInitRootController =
        [[ADJPreSdkInitRootController alloc] initWithInstanceId:instanceId
                                                          clock:strongSelf.clock
                                                  sdkConfigData:strongSelf.sdkConfigData
                                                  threadFactory:strongSelf.threadController
                                                  loggerFactory:strongSelf.logController
                                                 clientExecutor:strongSelf.clientExecutor
                                           clientReturnExecutor:clentReturnExecutor
                                             publishersRegistry:strongSelf.publishersRegistry];
    } source:@"ADJInstanceRoot init"];

    return self;

}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)initSdkWithConfiguration:(nonnull ADJAdjustConfig *)adjustConfig {

    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        // TODO: (Gena) rename this method
        ADJClientConfigData *_Nullable clientConfigData =
        [ADJClientConfigData instanceFromClientWithAdjustConfig:adjustConfig
                                                         logger:strongSelf.adjustApiLogger];

        if (clientConfigData == nil) {
            [strongSelf.adjustApiLogger
             errorClient:@"Cannot init SDK without valid Adjust configuration"];
            return;
        }

        if (NO == [strongSelf.preSdkInitRootController.sdkActiveController ccTrySdkInit]) {
            return;
        }

        id<ADJClientReturnExecutor> clentReturnExecutor =
        (strongSelf.sdkConfigData.clientReturnExecutorOverwrite) ? : strongSelf.threadController;

        strongSelf.postSdkInitRootController =
        [[ADJPostSdkInitRootController alloc] initWithLoggerFactory:strongSelf.logController
                                                      threadFactory:strongSelf.threadController
                                                     clientExecutor:strongSelf.clientExecutor
                                               clientReturnExecutor:clentReturnExecutor
                                              storageRootController:strongSelf.preSdkInitRootController.storageRootController
                                                   deviceController:strongSelf.preSdkInitRootController.deviceController
                                                   clientConfigData:clientConfigData
                                                      sdkConfigData:strongSelf.sdkConfigData
                                                              clock:strongSelf.clock
                                                 publishersRegistry:strongSelf.publishersRegistry];

        // Inject remaining dependencies before subscribing to publishers
        // 1. Self (InstanceRoot) dependencies - subscribe to publishers
        [strongSelf.publishersRegistry addSubscriberToPublishers:strongSelf.logController];
        // 2. PreSdkInit dependencies
        // Set dependencies from PostInitRootController
        [strongSelf.preSdkInitRootController.clientActionController ccSetDependenciesAtSdkInitWithPostSdkInitRootController:self.postSdkInitRootController];

        [strongSelf.preSdkInitRootController
             setDependenciesWithPackageBuilder:
                strongSelf.postSdkInitRootController.sdkPackageBuilder
             clock:strongSelf.clock
             loggerFactory:strongSelf.logController
             threadExecutorFactory:strongSelf.threadController
             sdkPackageSenderFactory:
                strongSelf.postSdkInitRootController.sdkPackageSenderController];
        // Subscribe to publishers
        [strongSelf.preSdkInitRootController subscribeToPublishers:strongSelf.publishersRegistry];

        // 3. PostSdkInit dependencies
        // Subscribe to publishers
        [strongSelf.postSdkInitRootController subscribeToPublishers:strongSelf.publishersRegistry];
        // Finalize init flow and start Sdk
        [strongSelf.postSdkInitRootController startSdk];
    } source:@"initSdkWithConfiguration"];
}

- (void)trackEvent:(nonnull ADJAdjustEvent *)adjustEvent {

    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        id<ADJClientActionsAPI> _Nullable clientActionsAPI = [self clientActionsApiForInstanceRoot:strongSelf
                                                                                      actionSource:@"trackEvent"];
        if (! clientActionsAPI) {
            return;
        }

        ADJClientEventData *_Nullable clientEventData =
        [ADJClientEventData instanceFromClientWithAdjustEvent:adjustEvent
                                                       logger:strongSelf.adjustApiLogger];

        if (clientEventData == nil) {
            [strongSelf.adjustApiLogger errorClient:@"Cannot track invalid Event"];
            return;
        }
        [clientActionsAPI ccTrackEventWithClientData:clientEventData];
    } source:@"trackEvent"];
}

- (void)trackAdRevenue:(nonnull ADJAdjustAdRevenue *)adjustAdRevenue {

    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [self clientActionsApiForInstanceRoot:strongSelf
                                 actionSource:@"trackAdRevenue"];

        if (! clientActionsAPI) {
            return;
        }

        ADJClientAdRevenueData *_Nullable clientAdRevenueData =
        [ADJClientAdRevenueData instanceFromClientWithAdjustAdRevenue:adjustAdRevenue
                                                               logger:strongSelf.adjustApiLogger];

        if (clientAdRevenueData == nil) {
            [strongSelf.adjustApiLogger errorClient:@"Cannot track invalid Ad Revenue Event"];
            return;
        }
        [clientActionsAPI ccTrackAdRevenueWithClientData:clientAdRevenueData];
    } source:@"trackAdRevenue"];
}

- (void)trackPushToken:(nonnull ADJAdjustPushToken *)adjustPushToken {

    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [self clientActionsApiForInstanceRoot:strongSelf
                                 actionSource:@"trackPushToken"];

        if (! clientActionsAPI) {
            return;
        }

        ADJClientPushTokenData *_Nullable clientPushTokenData =
        [ADJClientPushTokenData instanceFromClientWithAdjustPushToken:adjustPushToken
                                                               logger:strongSelf.adjustApiLogger];

        if (clientPushTokenData == nil) {
            [strongSelf.adjustApiLogger errorClient:@"Cannot track invalid Push Token"];
            return;
        }
        [clientActionsAPI ccTrackPushTokenWithClientData:clientPushTokenData];
    } source:@"trackPushToken"];
}

- (void)trackLaunchedDeeplink:(nonnull ADJAdjustLaunchedDeeplink *)adjustLaunchedDeeplink {

    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [self clientActionsApiForInstanceRoot:strongSelf
                                 actionSource:@"trackLaunchedDeeplink"];

        if (! clientActionsAPI) {
            return;
        }

        ADJClientLaunchedDeeplinkData *_Nullable clientLaunchedDeeplinkData =
        [ADJClientLaunchedDeeplinkData instanceFromClientWithAdjustLaunchedDeeplink:adjustLaunchedDeeplink
                                                                             logger:strongSelf.adjustApiLogger];

        if (clientLaunchedDeeplinkData == nil) {
            [strongSelf.adjustApiLogger errorClient:@"Cannot track invalid Deep Link"];
            return;
        }
        [clientActionsAPI ccTrackLaunchedDeeplinkWithClientData:clientLaunchedDeeplinkData];
    } source:@"trackLaunchedDeeplink"];
}

- (void)trackBillingSubscription:(nonnull ADJAdjustBillingSubscription *)adjustBillingSubscription {

    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [self clientActionsApiForInstanceRoot:strongSelf
                                 actionSource:@"trackBillingSubscription"];

        if (! clientActionsAPI) {
            return;
        }

        ADJClientBillingSubscriptionData *_Nullable clientBillingSubscriptionData =
        [ADJClientBillingSubscriptionData instanceFromClientWithAdjustBillingSubscription:adjustBillingSubscription
                                                                                   logger:strongSelf.adjustApiLogger];
        if (clientBillingSubscriptionData == nil) {
            return;
        }
        [clientActionsAPI ccTrackBillingSubscriptionWithClientData:clientBillingSubscriptionData];
    } source:@"trackBillingSubscription"];
}

- (void)trackThirdPartySharing:(nonnull ADJAdjustThirdPartySharing *)adjustThirdPartySharing {

    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [self clientActionsApiForInstanceRoot:strongSelf
                                 actionSource:@"trackThirdPartySharing"];

        if (! clientActionsAPI) {
            return;
        }

        ADJClientThirdPartySharingData *_Nullable clientThirdPartySharingData =
        [ADJClientThirdPartySharingData instanceFromClientWithAdjustThirdPartySharing:adjustThirdPartySharing
                                                                               logger:strongSelf.adjustApiLogger];
        if (clientThirdPartySharingData == nil) {
            return;
        }
        [clientActionsAPI ccTrackThirdPartySharingWithClientData:clientThirdPartySharingData];
    } source:@"trackThirdPartySharing"];
}

- (void)adjustAttributionWithCallback:(nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback {

    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        if (adjustAttributionCallback == nil) {
            [strongSelf.adjustApiLogger errorClient:@"Cannot get Adjust Attribution with nil callback"];
            return;
        }

        [strongSelf.preSdkInitRootController.clientCallbacksController ccAttributionWithCallback:adjustAttributionCallback];
    } source:@"adjustAttributionWithCallback"];
}

- (void)deviceIdsWithCallback:(nonnull id<ADJAdjustDeviceIdsCallback>)adjustDeviceIdsCallback {

    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        if (adjustDeviceIdsCallback == nil) {
            [strongSelf.adjustApiLogger errorClient:@"Cannot get Adjust Device Ids with nil callback"];
            return;
        }

        [strongSelf.preSdkInitRootController.clientCallbacksController ccDeviceIdsWithCallback:adjustDeviceIdsCallback];
    } source:@"deviceIdsWithCallback"];
}

- (void)gdprForgetDevice {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        BOOL bUpdatedForgottenStatus = [strongSelf.preSdkInitRootController.sdkActiveController ccGdprForgetDevice];
        if (! bUpdatedForgottenStatus) {
            return;
        }
        [strongSelf.preSdkInitRootController.gdprForgetController forgetDevice];
    } source:@"gdprForgetDevice"];
}

- (void)inactivateSdk {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.preSdkInitRootController.sdkActiveController ccInactivateSdk];
    } source:@"inactivateSdk"];
}

- (void)reactivateSdk {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.preSdkInitRootController.sdkActiveController ccReactivateSdk];
    } source:@"reactivateSdk"];
}

- (void)switchToOfflineMode {

    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        NSString *errMsg = nil;
        if (! [strongSelf.preSdkInitRootController.sdkActiveController ccCanPerformActionWithSource:@"switchToOfflineMode"
                                                                                       errorMessage:&errMsg]) {
            if (errMsg != nil && errMsg.length > 0) {
                [strongSelf.adjustApiLogger errorClient:[NSString stringWithFormat:@"%@", errMsg]];
            }
            return;
        }

        [strongSelf.preSdkInitRootController.offlineController ccPutSdkOffline];
    } source:@"switchToOfflineMode"];
}

- (void)switchBackToOnlineMode {

    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        NSString *errMsg = nil;
        if (! [strongSelf.preSdkInitRootController.sdkActiveController ccCanPerformActionWithSource:@"switchBackToOnlineMode"
                                                                                       errorMessage:&errMsg]) {
            if (errMsg != nil && errMsg.length > 0) {
                [strongSelf.adjustApiLogger errorClient:[NSString stringWithFormat:@"%@", errMsg]];
            }
            return;
        }

        [strongSelf.preSdkInitRootController.offlineController ccPutSdkOnline];
    } source:@"switchBackToOnlineMode"];
}

- (void)appWentToTheForegroundManualCall {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        [strongSelf.preSdkInitRootController.lifecycleController ccForeground];

        if (! strongSelf.postSdkInitRootController) {
            return;
        }
        [strongSelf.postSdkInitRootController.measurementSessionController ccForeground];
    } source:@"appWentToTheForegroundManualCall"];
}

- (void)appWentToTheBackgroundManualCall {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        [strongSelf.preSdkInitRootController.lifecycleController ccBackground];

        if (! strongSelf.postSdkInitRootController) {
            return;
        }
        [strongSelf.postSdkInitRootController.measurementSessionController ccBackground];
    } source:@"appWentToTheBackgroundManualCall"];
}

- (void)addGlobalCallbackParameterWithKey:(nonnull NSString *)key value:(nonnull NSString *)value {

    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [self clientActionsApiForInstanceRoot:strongSelf
                                 actionSource:@"addGlobalCallbackParameter"];

        if (! clientActionsAPI) {
            return;
        }

        ADJClientAddGlobalParameterData *_Nullable clientAddGlobalParameterData =
        [ADJClientAddGlobalParameterData instanceFromClientWithAdjustConfigWithKeyToAdd:key
                                                                             valueToAdd:value
                                                                                 logger:strongSelf.adjustApiLogger];
        if (clientAddGlobalParameterData == nil) {
            return;
        }
        [clientActionsAPI ccAddGlobalCallbackParameterWithClientData:clientAddGlobalParameterData];
    } source:@"addGlobalCallbackParameterWithKey"];
}

- (void)removeGlobalCallbackParameterByKey:(nonnull NSString *)key {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [self clientActionsApiForInstanceRoot:strongSelf
                                 actionSource:@"removeGlobalCallbackParameter"];

        if (! clientActionsAPI) {
            return;
        }

        ADJClientRemoveGlobalParameterData *_Nullable clientRemoveGlobalParameterData =
        [ADJClientRemoveGlobalParameterData instanceFromClientWithAdjustConfigWithKeyToRemove:key
                                                                                       logger:strongSelf.adjustApiLogger];

        if (clientRemoveGlobalParameterData == nil) {
            return;
        }
        [clientActionsAPI ccRemoveGlobalCallbackParameterWithClientData:clientRemoveGlobalParameterData];
    } source:@"removeGlobalCallbackParameterByKey"];
}

- (void)clearAllGlobalCallbackParameters {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [self clientActionsApiForInstanceRoot:strongSelf
                                 actionSource:@"clearAllGlobalCallbackParameters"];

        if (! clientActionsAPI) {
            return;
        }
        ADJClientClearGlobalParametersData *_Nonnull clientClearGlobalParametersData = [[ADJClientClearGlobalParametersData alloc] init];
        [clientActionsAPI ccClearGlobalCallbackParametersWithClientData:clientClearGlobalParametersData];
    } source:@"clearAllGlobalCallbackParameters"];
}

- (void)addGlobalPartnerParameterWithKey:(nonnull NSString *)key value:(nonnull NSString *)value {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [self clientActionsApiForInstanceRoot:strongSelf
                                 actionSource:@"addGlobalPartnerParameter"];

        if (! clientActionsAPI) {
            return;
        }

        ADJClientAddGlobalParameterData *_Nullable clientAddGlobalParameterData =
        [ADJClientAddGlobalParameterData instanceFromClientWithAdjustConfigWithKeyToAdd:key
                                                                             valueToAdd:value
                                                                                 logger:strongSelf.adjustApiLogger];
        if (clientAddGlobalParameterData == nil) {
            return;
        }
        [clientActionsAPI ccAddGlobalPartnerParameterWithClientData:clientAddGlobalParameterData];
    } source:@"addGlobalPartnerParameterWithKey"];
}

- (void)removeGlobalPartnerParameterByKey:(nonnull NSString *)key {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [self clientActionsApiForInstanceRoot:strongSelf
                                 actionSource:@"removeGlobalPartnerParameter"];

        if (! clientActionsAPI) {
            return;
        }

        ADJClientRemoveGlobalParameterData *_Nullable clientRemoveGlobalParameterData =
        [ADJClientRemoveGlobalParameterData instanceFromClientWithAdjustConfigWithKeyToRemove:key
                                                                                       logger:strongSelf.adjustApiLogger];

        if (clientRemoveGlobalParameterData == nil) {
            return;
        }
        [clientActionsAPI ccRemoveGlobalPartnerParameterWithClientData:clientRemoveGlobalParameterData];
    } source:@"removeGlobalPartnerParameterByKey"];
}

- (void)clearAllGlobalPartnerParameters {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [self clientActionsApiForInstanceRoot:strongSelf
                                 actionSource:@"clearAllGlobalPartnerParameters"];

        if (! clientActionsAPI) {
            return;
        }
        ADJClientClearGlobalParametersData *_Nonnull clientClearGlobalParametersData = [[ADJClientClearGlobalParametersData alloc] init];
        [clientActionsAPI ccClearGlobalPartnerParametersWithClientData:clientClearGlobalParametersData];
    } source:@"clearAllGlobalPartnerParameters"];
}

#pragma mark Internal methods
- (nullable id<ADJClientActionsAPI>)clientActionsApiForInstanceRoot:(ADJInstanceRoot *)instanceRoot
                                                       actionSource:(NSString *)source {
    NSString *errMsg = nil;
    if (! [instanceRoot.preSdkInitRootController.sdkActiveController ccCanPerformActionWithSource:source
                                                                                     errorMessage:&errMsg]) {
        if (errMsg != nil && errMsg.length > 0) {
            [instanceRoot.adjustApiLogger errorClient:[NSString stringWithFormat:@"%@", errMsg]];
        }
        return nil;
    }
    return [instanceRoot.postSdkInitRootController sdkStartClientActionAPI] ? : instanceRoot.preSdkInitRootController.clientActionController;
}


- (void)finalizeAtTeardownWithBlock:(nullable void (^)(void))closeStorageBlock {

    __typeof(self) __weak weakSelf = self;
    BOOL canExecuteTask = [self.clientExecutor executeInSequenceWithBlock:^{

        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        if (strongSelf.preSdkInitRootController != nil) {
            [strongSelf.preSdkInitRootController.storageRootController finalizeAtTeardownWithCloseStorageBlock:closeStorageBlock];
            [strongSelf.preSdkInitRootController.lifecycleController finalizeAtTeardown];
        }

        if (strongSelf.postSdkInitRootController != nil) {
            [strongSelf.postSdkInitRootController.reachabilityController finalizeAtTeardown];
        }

        [strongSelf.threadController finalizeAtTeardown];
    } source:@"finalizeAtTeardownWithBlock"];

    if (! canExecuteTask && closeStorageBlock != nil) {
        closeStorageBlock();
    }
}

@end
