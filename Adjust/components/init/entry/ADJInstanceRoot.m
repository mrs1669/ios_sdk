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
@property (nonnull, readonly, strong, nonatomic) ADJInstanceIdData *instanceId;

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
@property (nonnull, readonly, strong, nonatomic) ADJClock *clock;
@property (nonnull, readonly, strong, nonatomic) ADJPublisherController *publisherController;

@end

@implementation ADJInstanceRoot
#pragma mark Instantiation
- (nonnull instancetype)initWithConfigData:(nonnull ADJSdkConfigData *)configData
                                instanceId:(nonnull ADJInstanceIdData *)instanceId
{
    self = [super init];
    _sdkConfigData = configData;
    _instanceId = instanceId;

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

        strongSelf.postSdkInitRootController =
            [[ADJPostSdkInitRootController alloc]
             initWithLoggerFactory:strongSelf.logController
             threadFactory:strongSelf.threadController
             clientExecutor:strongSelf.clientExecutor
             clientReturnExecutor:strongSelf.preSdkInitRootController.clientReturnExecutor
             storageRootController:strongSelf.preSdkInitRootController.storageRootController
             deviceController:strongSelf.preSdkInitRootController.deviceController
             clientConfigData:clientConfigData
             sdkConfigData:strongSelf.sdkConfigData
             sdkPrefix:nil //TODO: to inject with session refac
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
    [self ccExecuteWithPreBlock:^(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot) {
        [preSdkInitRoot.sdkActiveController ccInactivateSdk];
    } source:@"inactivateSdk"];
}

- (void)reactivateSdk {
    [self ccExecuteWithPreBlock:^(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot) {
        [preSdkInitRoot.sdkActiveController ccReactivateSdk];
    } source:@"reactivateSdk"];
}

- (void)gdprForgetDevice {
    [self ccExecuteWithPreBlock:^(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot) {
        BOOL updatedForgottenStatus = [preSdkInitRoot.sdkActiveController ccGdprForgetDevice];
        if (! updatedForgottenStatus) { return; }

        [preSdkInitRoot.gdprForgetController forgetDevice];
    } source:@"gdprForgetDevice"];
}

- (void)appWentToTheForegroundManualCall {
    [self ccExecuteWithPreBlock:^(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot) {
        [preSdkInitRoot.lifecycleController ccForeground];
    } source:@"appWentToTheForegroundManualCall"];
}

- (void)appWentToTheBackgroundManualCall {
    [self ccExecuteWithPreBlock:^(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot) {
        [preSdkInitRoot.lifecycleController ccForeground];
    } source:@"appWentToTheBackgroundManualCall"];
}

- (void)switchToOfflineMode {
    [self ccWhenActiveWithPreBlock:^(ADJPreSdkInitRootController * _Nonnull preSdkInitRoot) {
        [preSdkInitRoot.offlineController ccPutSdkOffline];
    } clientSource:@"switchToOfflineMode"];
}

 - (void)switchBackToOnlineMode {
     [self ccWhenActiveWithPreBlock:^(ADJPreSdkInitRootController * _Nonnull preSdkInitRoot) {
         [preSdkInitRoot.offlineController ccPutSdkOffline];
     } clientSource:@"switchBackToOnlineMode"];
 }

- (void)deviceIdsWithCallback:(nonnull id<ADJAdjustDeviceIdsCallback>)adjustDeviceIdsCallback {
    [self ccWithAdjustCallback:adjustDeviceIdsCallback
                      preBlock:^(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot)
     {
        [preSdkInitRoot.clientCallbacksController
         ccDeviceIdsWithCallback:adjustDeviceIdsCallback
         clientReturnExecutor:preSdkInitRoot.clientReturnExecutor
         deviceController:preSdkInitRoot.deviceController];
    } clientSource:@"deviceIdsWithCallback"];
}

- (void)adjustAttributionWithCallback:
    (nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback
{
    [self ccWithAdjustCallback:adjustAttributionCallback
                      preBlock:^(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot)
     {
        [preSdkInitRoot.clientCallbacksController
         ccAttributionWithCallback:adjustAttributionCallback
         clientReturnExecutor:preSdkInitRoot.clientReturnExecutor
         attributionStateStorage:preSdkInitRoot.storageRootController.attributionStateStorage];
    } clientSource:@"adjustAttributionWithCallback"];
}

- (void)trackEvent:(nonnull ADJAdjustEvent *)adjustEvent {
    [self ccExecuteWithClientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                                            ADJLogger * _Nonnull logger)
     {
        ADJClientEventData *_Nullable clientData =
            [ADJClientEventData instanceFromClientWithAdjustEvent:adjustEvent
                                                           logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccTrackEventWithClientData:clientData];
    } clientSource:@"trackEvent"];
}

- (void)trackLaunchedDeeplink:(nonnull ADJAdjustLaunchedDeeplink *)adjustLaunchedDeeplink {
    [self ccExecuteWithClientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                                            ADJLogger * _Nonnull logger)
     {
        ADJClientLaunchedDeeplinkData *_Nullable clientData =
            [ADJClientLaunchedDeeplinkData
             instanceFromClientWithAdjustLaunchedDeeplink:adjustLaunchedDeeplink
             logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccTrackLaunchedDeeplinkWithClientData:clientData];
    } clientSource:@"trackLaunchedDeeplink"];
}

- (void)trackPushToken:(nonnull ADJAdjustPushToken *)adjustPushToken {
    [self ccExecuteWithClientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                                            ADJLogger * _Nonnull logger)
     {
        ADJClientPushTokenData *_Nullable clientData =
            [ADJClientPushTokenData
             instanceFromClientWithAdjustPushToken:adjustPushToken
             logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccTrackPushTokenWithClientData:clientData];
    } clientSource:@"trackPushToken"];
}

- (void)trackThirdPartySharing:(nonnull ADJAdjustThirdPartySharing *)adjustThirdPartySharing {
    [self ccExecuteWithClientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                                            ADJLogger * _Nonnull logger)
     {
        ADJClientThirdPartySharingData *_Nullable clientData =
            [ADJClientThirdPartySharingData
             instanceFromClientWithAdjustThirdPartySharing:adjustThirdPartySharing
             logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccTrackThirdPartySharingWithClientData:clientData];
    } clientSource:@"trackThirdPartySharing"];
}

- (void)trackAdRevenue:(nonnull ADJAdjustAdRevenue *)adjustAdRevenue {
    [self ccExecuteWithClientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                                            ADJLogger * _Nonnull logger)
     {
        ADJClientAdRevenueData *_Nullable clientData =
            [ADJClientAdRevenueData
             instanceFromClientWithAdjustAdRevenue:adjustAdRevenue
             logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccTrackAdRevenueWithClientData:clientData];
    } clientSource:@"trackAdRevenue"];
}

- (void)trackBillingSubscription:(nonnull ADJAdjustBillingSubscription *)adjustBillingSubscription {
    [self ccExecuteWithClientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                                            ADJLogger * _Nonnull logger)
     {
        ADJClientBillingSubscriptionData *_Nullable clientData =
            [ADJClientBillingSubscriptionData
             instanceFromClientWithAdjustBillingSubscription:adjustBillingSubscription
             logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccTrackBillingSubscriptionWithClientData:clientData];
    } clientSource:@"trackBillingSubscription"];
}

- (void)addGlobalCallbackParameterWithKey:(nonnull NSString *)key value:(nonnull NSString *)value {
    [self ccExecuteWithClientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                                            ADJLogger * _Nonnull logger)
     {
        ADJClientAddGlobalParameterData *_Nullable clientData =
            [ADJClientAddGlobalParameterData
             instanceFromClientWithAdjustConfigWithKeyToAdd:key
             valueToAdd:value
             logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccAddGlobalCallbackParameterWithClientData:clientData];
    } clientSource:@"addGlobalCallbackParameter"];
}
- (void)removeGlobalCallbackParameterByKey:(nonnull NSString *)key {
    [self ccExecuteWithClientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                                            ADJLogger * _Nonnull logger)
     {
        ADJClientRemoveGlobalParameterData *_Nullable clientData =
            [ADJClientRemoveGlobalParameterData
             instanceFromClientWithAdjustConfigWithKeyToRemove:key
             logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccRemoveGlobalCallbackParameterWithClientData:clientData];
    } clientSource:@"removeGlobalCallbackParameter"];
}
- (void)clearAllGlobalCallbackParameters {
    [self ccExecuteWithClientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                                            ADJLogger * _Nonnull logger)
     {
        ADJClientClearGlobalParametersData *_Nonnull clientData =
            [[ADJClientClearGlobalParametersData alloc] init];

        [clientActionsAPI ccClearGlobalCallbackParametersWithClientData:clientData];
    } clientSource:@"clearAllGlobalCallbackParameters"];
}

- (void)addGlobalPartnerParameterWithKey:(nonnull NSString *)key value:(nonnull NSString *)value {
    [self ccExecuteWithClientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                                            ADJLogger * _Nonnull logger)
     {
        ADJClientAddGlobalParameterData *_Nullable clientData =
            [ADJClientAddGlobalParameterData
             instanceFromClientWithAdjustConfigWithKeyToAdd:key
             valueToAdd:value
             logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccAddGlobalPartnerParameterWithClientData:clientData];
    } clientSource:@"addGlobalPartnerParameter"];
}

- (void)removeGlobalPartnerParameterByKey:(nonnull NSString *)key {
    [self ccExecuteWithClientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                                            ADJLogger * _Nonnull logger)
     {
        ADJClientRemoveGlobalParameterData *_Nullable clientData =
            [ADJClientRemoveGlobalParameterData
             instanceFromClientWithAdjustConfigWithKeyToRemove:key
             logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccRemoveGlobalPartnerParameterWithClientData:clientData];
    } clientSource:@"removeGlobalPartnerParameter"];
}

- (void)clearAllGlobalPartnerParameters {
    [self ccExecuteWithClientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                                            ADJLogger * _Nonnull logger)
     {
        ADJClientClearGlobalParametersData *_Nonnull clientData =
            [[ADJClientClearGlobalParametersData alloc] init];

        [clientActionsAPI ccClearGlobalPartnerParametersWithClientData:clientData];
    } clientSource:@"clearAllGlobalPartnerParameters"];
}

#pragma mark Internal methods
- (void)
    ccExecuteWithPreBlock:
        (void (^_Nonnull)(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot))preBlock
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
        preBlock(preSdkInitRootLocal);
    } source:source];
}

- (void)
    ccWhenActiveWithPreBlock:
        (void (^_Nonnull)(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot))preBlock
    clientSource:(nonnull NSString *)clientSource
{
    [self ccExecuteWithPreBlock:^(ADJPreSdkInitRootController * _Nonnull preSdkInitRoot) {
        if ([preSdkInitRoot.sdkActiveController
             ccCanPerformActionWithClientSource:clientSource])
        {
            preBlock(preSdkInitRoot);
        }
    } source:clientSource];
}

- (void)
    ccWithAdjustCallback:(nullable id<ADJAdjustCallback>)adjustCallback
    preBlock:(void (^_Nonnull)(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot))preBlock
    clientSource:(nonnull NSString *)clientSource
{
    [self ccExecuteWithPreBlock:^(ADJPreSdkInitRootController * _Nonnull preSdkInitRoot) {
        if (adjustCallback == nil) {
            [preSdkInitRoot.logger errorClient:@"Cannot use invalid callback"
                                               from:clientSource];
            return;
        }

        NSString *_Nullable cannotPerformMessage =
            [preSdkInitRoot.sdkActiveController
             ccCanPerformActionOrElseMessageWithClientSource:clientSource];

        if (cannotPerformMessage != nil) {
            [preSdkInitRoot.clientCallbacksController
             failWithAdjustCallback:adjustCallback
             clientReturnExecutor:preSdkInitRoot.clientReturnExecutor
             cannotPerformMessage:cannotPerformMessage];
            return;
        }

        preBlock(preSdkInitRoot);
    } source:clientSource];
}

- (void)
    ccExecuteWithClientActionsBlock:
        (void (^_Nonnull)(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger))clientActionsBlock
    clientSource:(nonnull NSString *)clientSource
{
    [self ccWhenActiveWithPreBlock:^(ADJPreSdkInitRootController *_Nonnull preSdkInitRoot) {
        // TODO change to sync with Android
        id<ADJClientActionsAPI> _Nonnull clientActionsAPI =
            [self.postSdkInitRootController sdkStartClientActionAPI]
            ? : preSdkInitRoot.clientActionController;

        clientActionsBlock(clientActionsAPI, preSdkInitRoot.logger);
    } clientSource:clientSource];
}

@end
