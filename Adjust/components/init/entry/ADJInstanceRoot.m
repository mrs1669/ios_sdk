//
//  ADJInstanceRoot.m
//  Adjust
//
//  Created by Genady Buchatsky on 04.11.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJInstanceRoot.h"

#import "ADJLogger.h"
#import "ADJSdkConfigData.h"
#import "ADJPreSdkInitRoot.h"
#import "ADJPostSdkInitRoot.h"
#import "ADJPostSdkStartRoot.h"
#import "ADJPublisherController.h"
#import "ADJConstants.h"
#import "ADJConsoleLogger.h"

@interface ADJInstanceRoot ()
#pragma mark - Internal variables
@property (nullable, readonly, weak, nonatomic) id<ADJEntryRootBag> entryRootBagWeak;
@property (nullable, readwrite, strong, nonatomic) ADJPreSdkInitRoot *preSdkInitRoot;
@property (nullable, readwrite, strong, nonatomic) ADJPostSdkInitRoot *postSdkInitRoot;
@property (nonnull, readonly, strong, nonatomic) ADJLogger *logger;

@end

@implementation ADJInstanceRoot
#pragma mark - Synthesize protocol properties
@synthesize sdkConfigData = _sdkConfigData;
@synthesize instanceId = _instanceId;
@synthesize logController = _logController;
@synthesize threadController = _threadController;
@synthesize clientExecutor = _clientExecutor;
@synthesize commonExecutor = _commonExecutor;
@synthesize clock = _clock;
@synthesize publisherController = _publisherController;

#pragma mark Instantiation
+ (nonnull instancetype)instanceWithConfigData:(nonnull ADJSdkConfigData *)configData
                                    instanceId:(nonnull ADJInstanceIdData *)instanceId
                                  entryRootBag:(nonnull id<ADJEntryRootBag>)entryRootBag
{
    ADJInstanceRoot *_Nonnull instanceRoot =
    [[ADJInstanceRoot alloc] initWithConfigData:configData
                                     instanceId:instanceId
                                   entryRootBag:entryRootBag];

    [instanceRoot createPreSdkInitRootInClientContext];

    return instanceRoot;
}

- (nonnull instancetype)initWithConfigData:(nonnull ADJSdkConfigData *)configData
                                instanceId:(nonnull ADJInstanceIdData *)instanceId
                              entryRootBag:(nonnull id<ADJEntryRootBag>)entryRootBag
{
    self = [super init];
    _sdkConfigData = configData;
    _instanceId = instanceId;
    _entryRootBagWeak = entryRootBag;

    _clock = [[ADJClock alloc] init];

    _publisherController = [[ADJPublisherController alloc] init];

    _logController = [[ADJLogController alloc] initWithSdkConfigData:configData
                                                 publisherController:_publisherController
                                                          instanceId:instanceId];

    _threadController = [[ADJThreadController alloc] initWithLoggerFactory:_logController];

    _clientExecutor = [_threadController
                       createSingleThreadExecutorWithLoggerFactory:_logController
                       sourceLoggerName:@"clientExecutor"];
    _commonExecutor = [_threadController
                       createSingleThreadExecutorWithLoggerFactory:_logController
                       sourceLoggerName:@"commonExecutor"];
    [_logController injectDependeciesWithCommonExecutor:_commonExecutor];

    _logger = [_logController createLoggerWithName:@"InstanceRoot"];

    return self;
}

- (void)createPreSdkInitRootInClientContext {
    __typeof(self) __weak weakSelf = self;
    [_clientExecutor executeInSequenceWithLogger:self.logger
                                                from:@"Create PreSdkInitRoot in ClientContext"
                                               block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        strongSelf.preSdkInitRoot = [[ADJPreSdkInitRoot alloc] initWithInstanceRootBag:strongSelf];
    }];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nullable NSString *)sdkPrefix {
    id<ADJEntryRootBag> _Nullable entryRootBag = self.entryRootBagWeak;
    if (entryRootBag == nil) {
        [self.logger debugDev:@"Cannot return sdk prefix without entry root reference"
                    issueType:ADJIssueWeakReference];
        return nil;
    }

    return entryRootBag.sdkPrefix;
}

- (void)finalizeAtTeardownWithBlock:(nullable void (^)(void))closeStorageBlock {
    __typeof(self) __weak weakSelf = self;
    ADJResultFail *_Nullable execFail =
        [self.clientExecutor executeInSequenceFrom:@"finalizeAtTeardownWithBlock"
                                             block:^{
            __typeof(weakSelf) __strong strongSelf = weakSelf;
            if (strongSelf == nil) {
                return;
            }

            if (strongSelf.preSdkInitRoot != nil) {
                [strongSelf.preSdkInitRoot finalizeAtTeardownWithBlock:closeStorageBlock];
            }

            if (strongSelf.postSdkInitRoot != nil) {
                [strongSelf.postSdkInitRoot finalizeAtTeardownWithBlock:closeStorageBlock];
            }

            [strongSelf.threadController finalizeAtTeardown];
        }];

    if (execFail != nil) {
        [self.logger debugDev:@"Failed to execute finalize at teardwon"
                   resultFail:execFail
                    issueType:ADJIssueThreadsAndLocks];

        if (closeStorageBlock != nil) {
            closeStorageBlock();
        }
    }
}

- (void)
    initSdkWithConfig:(nonnull ADJAdjustConfig *)adjustConfig
    internalConfigSubscriptions:
        (nullable NSDictionary<NSString *, id<ADJInternalCallback>> *)internalConfigSubscriptions
{
    [self ccExecuteFrom:@"initSdk"
        preAndSelfBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot,
                          ADJInstanceRoot *_Nonnull instanceRoot)
     {
        ADJClientConfigData *_Nullable clientConfig =
            [ADJClientConfigData
             instanceFromClientWithAdjustConfig:adjustConfig
             internalConfigSubscriptions:internalConfigSubscriptions
             logger:preSdkInitRoot.logger];

        if (! [preSdkInitRoot.sdkActiveController ccTrySdkInit]) {
            return;
        }

        // Initialize PostSdkInitRoot instance
        instanceRoot.postSdkInitRoot =
            [[ADJPostSdkInitRoot alloc] initWithClientConfig:clientConfig
                                             instanceRootBag:instanceRoot
                                           preSdkInitRootBag:preSdkInitRoot];

        // Inject remaining dependencies before subscriptions
        [preSdkInitRoot
         ccSetDependenciesAtSdkInitWithInstanceRootBag:instanceRoot
         postSdkInitRootBag:instanceRoot.postSdkInitRoot
         clientActionsPostSdkStart:instanceRoot.postSdkInitRoot.postSdkStartRoot];

        // Subscribe to publishers
        [instanceRoot ccSubscribeToPublishers:instanceRoot.publisherController];
        [preSdkInitRoot ccSubscribeToPublishers:instanceRoot.publisherController];
        [instanceRoot.postSdkInitRoot ccSubscribeToPublishers:instanceRoot.publisherController];

        // Finalize Initialization process
        [instanceRoot.postSdkInitRoot ccCompletePostSdkInit];
    }];
}

- (void)adjustAttributionWithInternalCallback:(nonnull id<ADJInternalCallback>)internalCallback {
    [self ccExecuteFrom:@"adjustAttributionWithInternalCallback"
       internalCallback:internalCallback
         failMethodName:ADJAttributionGetterFailedMethodName
               preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot)
     {
        [preSdkInitRoot.clientCallbacksController
         ccAttributionWithInternalCallback:internalCallback
         attributionStateReadOnlyStorage:preSdkInitRoot.storageRoot.attributionStateStorage];
    }];
}

- (void)adjustDeviceIdsWithInternalCallback:(nonnull id<ADJInternalCallback>)internalCallback {
    [self ccExecuteFrom:@"adjustDeviceIdsWithInternalCallback"
       internalCallback:internalCallback
         failMethodName:ADJDeviceIdsGetterFailedMethodName
               preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot)
     {
        [preSdkInitRoot.clientCallbacksController
         ccDeviceIdsWithInternalCallback:internalCallback
         deviceController:preSdkInitRoot.deviceController];
    }];
}

#pragma mark - ADJAdjustInstance
- (void)initSdkWithConfig:(nonnull ADJAdjustConfig *)adjustConfig {
    [self initSdkWithConfig:adjustConfig
        internalConfigSubscriptions:nil];
}

- (void)inactivateSdk {
    [self ccExecuteFrom:@"inactivateSdk"
               preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot) {
        [preSdkInitRoot.sdkActiveController ccInactivateSdk];
    }];
}

- (void)reactivateSdk {
    [self ccExecuteFrom:@"reactivateSdk"
               preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot) {
        [preSdkInitRoot.sdkActiveController ccReactivateSdk];
    }];
}

- (void)gdprForgetDevice {
    [self ccExecuteFrom:@"gdprForgetDevice"
               preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot) {
        BOOL updatedForgottenStatus = [preSdkInitRoot.sdkActiveController ccGdprForgetDevice];
        if (! updatedForgottenStatus) { return; }

        [preSdkInitRoot.gdprForgetController forgetDevice];
    }];
}

- (void)appWentToTheForegroundManualCall {
    [self ccExecuteFrom:@"appWentToTheForegroundManualCall"
               preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot) {
        [preSdkInitRoot.lifecycleController ccForeground];
    }];
}

- (void)appWentToTheBackgroundManualCall {
    [self ccExecuteFrom:@"appWentToTheBackgroundManualCall"
               preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot) {
        [preSdkInitRoot.lifecycleController ccBackground];
    }];
}

- (void)switchToOfflineMode {
    [self ccWhenActiveFrom:@"switchToOfflineMode"
                  preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot) {
        [preSdkInitRoot.offlineController ccPutSdkOffline];
    }];
}

 - (void)switchBackToOnlineMode {
     [self ccWhenActiveFrom:@"switchBackToOnlineMode"
                   preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot) {
         [preSdkInitRoot.offlineController ccPutSdkOnline];
     }];
 }

- (void)activateMeasurementConsent {
    [self ccExecuteFrom:@"activateMeasurementConsent"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientMeasurementConsentData *_Nullable consentData =
            [ADJClientMeasurementConsentData instanceWithActivateConsent];
        if (consentData == nil) { return; }

        [clientActionsAPI ccTrackMeasurementConsent:consentData];
    }];
}

- (void)inactivateMeasurementConsent {
    [self ccExecuteFrom:@"inactivateMeasurementConsent"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientMeasurementConsentData *_Nullable consentData =
        [ADJClientMeasurementConsentData instanceWithInactivateConsent];
        if (consentData == nil) { return; }

        [clientActionsAPI ccTrackMeasurementConsent:consentData];
    }];
}

- (void)deviceIdsWithCallback:(nonnull id<ADJAdjustDeviceIdsCallback>)adjustDeviceIdsCallback {
    [self ccExecuteFrom:@"deviceIdsWithCallback"
         adjustCallback:adjustDeviceIdsCallback
               preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot)
     {
        [preSdkInitRoot.clientCallbacksController
         ccDeviceIdsWithAdjustCallback:adjustDeviceIdsCallback
         deviceController:preSdkInitRoot.deviceController];
    }];
}
- (void)adjustAttributionWithCallback:
    (nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback
{
    [self ccExecuteFrom:@"adjustAttributionWithCallback"
         adjustCallback:adjustAttributionCallback
               preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot)
     {
        [preSdkInitRoot.clientCallbacksController
         ccAttributionWithCallback:adjustAttributionCallback
         attributionStateReadOnlyStorage:preSdkInitRoot.storageRoot.attributionStateStorage];
    }];
}

- (void)adjustLaunchedDeeplinkWithCallback:
    (nonnull id<ADJAdjustLaunchedDeeplinkCallback>)adjustLaunchedDeeplinkCallback
{
    [self ccExecuteFrom:@"adjustLaunchedDeeplinkWithCallback"
         adjustCallback:adjustLaunchedDeeplinkCallback
               preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot)
     {
        [preSdkInitRoot.clientCallbacksController
         ccLaunchedDeepLinkWithCallback:adjustLaunchedDeeplinkCallback
         clientReturnExecutor:preSdkInitRoot.clientReturnExecutor
         LaunchedDeeplinkStateStorage:preSdkInitRoot.storageRoot.launchedDeeplinkStateStorage];
    }];
}

- (void)trackEvent:(nonnull ADJAdjustEvent *)adjustEvent {
    [self ccExecuteFrom:@"trackEvent"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientEventData *_Nullable clientData =
        [ADJClientEventData instanceFromClientWithAdjustEvent:adjustEvent
                                                       logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccTrackEventWithClientData:clientData];
    }];
}

- (void)trackLaunchedDeeplink:(nonnull ADJAdjustLaunchedDeeplink *)adjustLaunchedDeeplink {
    [self ccExecuteFrom:@"trackLaunchedDeeplink"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientLaunchedDeeplinkData *_Nullable clientData =
        [ADJClientLaunchedDeeplinkData
         instanceFromClientWithAdjustLaunchedDeeplink:adjustLaunchedDeeplink
         logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccTrackLaunchedDeeplinkWithClientData:clientData];
    }];
}

- (void)trackPushToken:(nonnull ADJAdjustPushToken *)adjustPushToken {
    [self ccExecuteFrom:@"trackPushToken"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientPushTokenData *_Nullable clientData =
        [ADJClientPushTokenData
         instanceFromClientWithAdjustPushToken:adjustPushToken
         logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccTrackPushTokenWithClientData:clientData];
    }];
}

- (void)trackThirdPartySharing:(nonnull ADJAdjustThirdPartySharing *)adjustThirdPartySharing {
    [self ccExecuteFrom:@"trackThirdPartySharing"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientThirdPartySharingData *_Nullable clientData =
        [ADJClientThirdPartySharingData
         instanceFromClientWithAdjustThirdPartySharing:adjustThirdPartySharing
         logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccTrackThirdPartySharingWithClientData:clientData];
    }];
}

- (void)trackAdRevenue:(nonnull ADJAdjustAdRevenue *)adjustAdRevenue {
    [self ccExecuteFrom:@"trackAdRevenue"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientAdRevenueData *_Nullable clientData =
        [ADJClientAdRevenueData
         instanceFromClientWithAdjustAdRevenue:adjustAdRevenue
         logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccTrackAdRevenueWithClientData:clientData];
    }];
}

- (void)trackBillingSubscription:
    (nonnull ADJAdjustBillingSubscription *)adjustBillingSubscription
{
    [self ccExecuteFrom:@"trackBillingSubscription"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientBillingSubscriptionData *_Nullable clientData =
        [ADJClientBillingSubscriptionData
         instanceFromClientWithAdjustBillingSubscription:adjustBillingSubscription
         logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccTrackBillingSubscriptionWithClientData:clientData];
    }];
}

- (void)addGlobalCallbackParameterWithKey:(nonnull NSString *)key
                                    value:(nonnull NSString *)value
{
    [self ccExecuteFrom:@"addGlobalCallbackParameter"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientAddGlobalParameterData *_Nullable clientData =
            [ADJClientAddGlobalParameterData
             instanceFromClientWithAdjustConfigWithKeyToAdd:key
             valueToAdd:value
             globalParameterType:ADJGlobalParametersTypeCallback
             logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccAddGlobalCallbackParameterWithClientData:clientData];
    }];
}

- (void)removeGlobalCallbackParameterByKey:(nonnull NSString *)key {
    [self ccExecuteFrom:@"removeGlobalCallbackParameter"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientRemoveGlobalParameterData *_Nullable clientData =
            [ADJClientRemoveGlobalParameterData
             instanceFromClientWithAdjustConfigWithKeyToRemove:key
             globalParameterType:ADJGlobalParametersTypeCallback
             logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccRemoveGlobalCallbackParameterWithClientData:clientData];
    }];
}
- (void)clearGlobalCallbackParameters {
    [self ccExecuteFrom:@"clearGlobalCallbackParameters"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientClearGlobalParametersData *_Nonnull clientData =
        [[ADJClientClearGlobalParametersData alloc] init];

        [clientActionsAPI ccClearGlobalCallbackParametersWithClientData:clientData];
    }];
}

- (void)addGlobalPartnerParameterWithKey:(nonnull NSString *)key
                                   value:(nonnull NSString *)value
{
    [self ccExecuteFrom:@"addGlobalPartnerParameter"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientAddGlobalParameterData *_Nullable clientData =
            [ADJClientAddGlobalParameterData
             instanceFromClientWithAdjustConfigWithKeyToAdd:key
             valueToAdd:value
             globalParameterType:ADJGlobalParametersTypePartner
             logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccAddGlobalPartnerParameterWithClientData:clientData];
    }];
}

- (void)removeGlobalPartnerParameterByKey:(nonnull NSString *)key {
    [self ccExecuteFrom:@"removeGlobalPartnerParameter"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientRemoveGlobalParameterData *_Nullable clientData =
            [ADJClientRemoveGlobalParameterData
             instanceFromClientWithAdjustConfigWithKeyToRemove:key
             globalParameterType:ADJGlobalParametersTypePartner
             logger:logger];
        if (clientData == nil) { return; }

        [clientActionsAPI ccRemoveGlobalPartnerParameterWithClientData:clientData];
    }];
}

- (void)clearGlobalPartnerParameters {
    [self ccExecuteFrom:@"clearGlobalPartnerParameters"
     clientActionsBlock:^(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                          ADJLogger *_Nonnull logger)
     {
        ADJClientClearGlobalParametersData *_Nonnull clientData =
        [[ADJClientClearGlobalParametersData alloc] init];

        [clientActionsAPI ccClearGlobalPartnerParametersWithClientData:clientData];
    }];
}

#pragma mark Internal methods
- (void)ccExecuteFrom:(nonnull NSString *)from
             preBlock:(void (^_Nonnull)(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot))preBlock
 {
     [self ccExecuteFrom:from
         preAndSelfBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot,
                           ADJInstanceRoot *_Nonnull instanceRoot) {
         preBlock(preSdkInitRoot);
     }];
}
- (void)ccExecuteFrom:(nonnull NSString *)from
      preAndSelfBlock:(void (^_Nonnull)
                       (ADJPreSdkInitRoot *_Nonnull preSdkInitRoot,
                        ADJInstanceRoot *_Nonnull instanceRoot))preAndSelfBlock
 {
     __typeof(self) __weak weakSelf = self;
     [self.clientExecutor executeInSequenceWithLogger:self.logger
                                                     from:from
                                                    block:^{
         __typeof(weakSelf) __strong strongSelf = weakSelf;
         if (strongSelf == nil) { return; }

         ADJPreSdkInitRoot *_Nullable preSdkInitRootLocal = strongSelf.preSdkInitRoot;
         if (preSdkInitRootLocal == nil) {
             [strongSelf.logger debugDev:@"Unexpected invalid PreSdkInitRoot"
                                    from:from
                              resultFail:nil
                               issueType:ADJIssueLogicError];
             return;
         }

         preAndSelfBlock(preSdkInitRootLocal, strongSelf);
     }];
}

- (void)
    ccWhenActiveFrom:(nonnull NSString *)from
    preBlock:(void (^_Nonnull)(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot))preBlock
{
    [self ccExecuteFrom:from
               preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot) {
        ADJResultFail *_Nullable cannotPerformFail =
            [preSdkInitRoot.sdkActiveController ccCanPerformClientAction];
        if (cannotPerformFail != nil) {
            [preSdkInitRoot.logger errorClient:@"Sdk cannot perform action"
                                           from:from
                                    resultFail:cannotPerformFail];
            return;
        }

        preBlock(preSdkInitRoot);
    }];
}

- (void)
    ccExecuteFrom:(nonnull NSString *)from
    internalCallback:(nonnull id<ADJInternalCallback>)internalCallback
    failMethodName:(nonnull NSString *)failMethodName
    preBlock:(void (^_Nonnull)(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot))preBlock
{
    [self ccExecuteFrom:from
               preBlock:^(ADJPreSdkInitRoot * _Nonnull preSdkInitRoot) {
        ADJResultFail *_Nullable cannotPerformFail =
            [preSdkInitRoot.sdkActiveController ccCanPerformClientAction];
        if (cannotPerformFail != nil) {
            [preSdkInitRoot.logger errorClient:@"Sdk cannot perform action with callback"
                                           from:from
                                    resultFail:cannotPerformFail];

            [preSdkInitRoot.clientCallbacksController
             failWithInternalCallback:internalCallback
             failMethodName:failMethodName
             cannotPerformFail:cannotPerformFail
             from:from];

            return;
        }

        preBlock(preSdkInitRoot);
    }];
}

- (void)
    ccExecuteFrom:(nonnull NSString *)from
    adjustCallback:(nullable id<ADJAdjustCallback>)adjustCallback
    preBlock:(void (^_Nonnull)(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot))preBlock
{
    [self ccExecuteFrom:from
               preBlock:^(ADJPreSdkInitRoot * _Nonnull preSdkInitRoot) {
        if (adjustCallback == nil) {
            [preSdkInitRoot.logger errorClient:@"Cannot use invalid callback"
                                           from:from
                                    resultFail:nil];
            return;
        }

        ADJResultFail *_Nullable cannotPerformFail =
            [preSdkInitRoot.sdkActiveController ccCanPerformClientAction];
        if (cannotPerformFail != nil) {
            [preSdkInitRoot.logger errorClient:@"Sdk cannot perform action with adjust callback"
                                           from:from
                                    resultFail:cannotPerformFail];

            [preSdkInitRoot.clientCallbacksController
             failWithAdjustCallback:adjustCallback
             cannotPerformFail:cannotPerformFail
             from:from];

            return;
        }

        preBlock(preSdkInitRoot);
    }];
}

- (void)
    ccExecuteFrom:(nonnull NSString *)from
    clientActionsBlock:(void (^_Nonnull)(id<ADJClientActionsAPI> _Nonnull clientActionsAPI,
                                         ADJLogger *_Nonnull logger))clientActionsBlock
{
    [self ccWhenActiveFrom:from
                  preBlock:^(ADJPreSdkInitRoot *_Nonnull preSdkInitRoot) {
        clientActionsBlock([preSdkInitRoot.clientActionController ccClientMeasurementActions],
                           preSdkInitRoot.logger);
    }];
}

- (void)ccSubscribeToPublishers:(ADJPublisherController *)publisherController {
    [publisherController subscribeToPublisher:self.logController];
}

@end


