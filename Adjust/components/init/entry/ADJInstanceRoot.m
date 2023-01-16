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
#import "ADJPublisherController.h"

@interface ADJInstanceRoot ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSdkConfigData *sdkConfigData;
@property (nullable, readonly, strong, nonatomic) NSString *instanceId;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJLogController *logController;
@property (nonnull, readonly, strong, nonatomic) ADJThreadController *threadController;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *clientExecutor;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *commonExecutor;
@property (nonnull, readonly, strong, nonatomic) ADJLogger *adjustApiLogger;
@property (nullable, readwrite, strong, nonatomic)
    ADJPreSdkInitRootController *preSdkInitRootController;
@property (nullable, readwrite, strong, nonatomic)
    ADJPostSdkInitRootController *postSdkInitRootController;
@property (nonnull, readwrite, strong, nonatomic) ADJClock *clock;
@property (nonnull, readonly, strong, nonatomic) ADJPublisherController *publisherController;

@end

@implementation ADJInstanceRoot
#pragma mark Instantiation
- (nonnull instancetype)initWithConfigData:(nonnull ADJSdkConfigData *)configData
                                instanceId:(nonnull NSString *)instanceId
{
    self = [super init];
    _sdkConfigData = configData;
    _instanceId = [instanceId copy];

    _clock = [[ADJClock alloc] init];

    _publisherController = [[ADJPublisherController alloc] init];

    _logController = [[ADJLogController alloc] initWithSdkConfigData:configData
                                                 publisherController:_publisherController
                                                          instanceId:instanceId];

    _threadController = [[ADJThreadController alloc] initWithLoggerFactory:_logController];

    // Executors
    _clientExecutor = [_threadController
                       createSingleThreadExecutorWithLoggerFactory:_logController
                       sourceDescription:@"clientExecutor"];
    _commonExecutor = [_threadController
                       createSingleThreadExecutorWithLoggerFactory:_logController
                       sourceDescription:@"commonExecutor"];
    [_logController injectDependeciesWithCommonExecutor:_commonExecutor];

    _adjustApiLogger = [_logController createLoggerWithSource:@"Adjust"];

    __typeof(self) __weak weakSelf = self;
    [_clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        strongSelf.preSdkInitRootController =
            [[ADJPreSdkInitRootController alloc] initWithInstanceId:instanceId
                                                              clock:strongSelf.clock
                                                      sdkConfigData:strongSelf.sdkConfigData
                                                   threadController:strongSelf.threadController
                                                      loggerFactory:strongSelf.logController
                                                     clientExecutor:strongSelf.clientExecutor
                                                publisherController:strongSelf.publisherController];
    } source:@"ADJInstanceRoot init"];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
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

#pragma mark - ADJAdjustInstance
- (void)sdkInitWithConfiguration:(nonnull ADJAdjustConfig *)adjustConfig {
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
                                                 publisherController:strongSelf.publisherController];

        // Inject remaining dependencies before subscribing to publishers
        // 1. Self (InstanceRoot) dependencies - subscribe to publishers
        [strongSelf.publisherController subscribeToPublisher:strongSelf.logController];
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
        [strongSelf.preSdkInitRootController subscribeToPublishers:strongSelf.publisherController];

        // 3. PostSdkInit dependencies
        // Subscribe to publishers
        [strongSelf.postSdkInitRootController subscribeToPublishers:strongSelf.publisherController];
        // Finalize init flow and start Sdk
        [strongSelf.postSdkInitRootController startSdk];
    } source:@"sdkInitWithConfiguration"];
}


- (void)inactivateSdk {
    [self ccExecuteWithPre:^(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot) {
        [preSdkInitRoot.sdkActiveController ccInactivateSdk];
    } source:@"inactivateSdk"];
}

- (void)reactivateSdk {
    [self ccExecuteWithPre:^(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot) {
        [preSdkInitRoot.sdkActiveController ccReactivateSdk];
    } source:@"reactivateSdk"];
}

- (void)gdprForgetDevice {
    [self ccExecuteWithPre:^(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot) {
        BOOL updatedForgottenStatus = [preSdkInitRoot.sdkActiveController ccGdprForgetDevice];
        if (! updatedForgottenStatus) { return; }

        [preSdkInitRoot.gdprForgetController forgetDevice];
    } source:@"gdprForgetDevice"];
}

- (void)appWentToTheForegroundManualCall {
    [self ccExecuteWithPre:^(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot) {
        [preSdkInitRoot.lifecycleController ccForeground];
    } source:@"appWentToTheForegroundManualCall"];
}

- (void)appWentToTheBackgroundManualCall {
    [self ccExecuteWithPre:^(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot) {
        [preSdkInitRoot.lifecycleController ccForeground];
    } source:@"appWentToTheBackgroundManualCall"];
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
- (void)
    ccExecuteWithPre:(void (^_Nonnull)(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot))block
    source:(nonnull NSString *)source
{
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        ADJPreSdkInitRootController *_Nullable preSdkInitRootLocal =
            strongSelf.preSdkInitRootController;
        if (preSdkInitRootLocal == nil) {
            [strongSelf.adjustApiLogger debugDev:@"Unexpected invalid PreSdkInitRoot"
                                            from:source
                                       issueType:ADJIssueLogicError];
            return;
        }
        block(preSdkInitRootLocal);
    } source:source];
}

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

@end
