//
//  ADJAdjust.m
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//

#import "ADJAdjust.h"

#import "ADJAdjustConfig.h"
#import "ADJAdjustEvent.h"
#import "ADJAdjustAdRevenue.h"
#import "ADJAdjustPushToken.h"
#import "ADJAdjustLaunchedDeeplink.h"
#import "ADJAdjustAttributionCallback.h"
#import "ADJAdjustDeviceIdsCallback.h"
#import "ADJAdjustBillingSubscription.h"
#import "ADJAdjustThirdPartySharing.h"
#import "ADJAdjustAttributionCallback.h"
#import "ADJAdjustDeviceIdsCallback.h"

#import "ADJEntryRoot.h"
#import "ADJClientConfigData.h"
#import "ADJSdkConfigDataBuilder.h"

@implementation ADJAdjust

#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Internal Constructors

#pragma mark - Public API
#pragma mark Initialize SDK Config
+ (void)sdkInitWithAdjustConfig:(nonnull ADJAdjustConfig *)adjustConfig {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger) {
        ADJClientConfigData *_Nullable clientConfigData =
            [ADJClientConfigData
                instanceFromClientWithAdjustConfig:adjustConfig
                logger:apiLogger];
        if (clientConfigData == nil) {
            [apiLogger error:@"Cannot init SDK without valid adjust config"];
            return;
        }

        [adjustAPI ccSdkInitWithClientConfigData:clientConfigData];
    }];
}

#pragma mark Offline/ Online Methods
+ (void)switchToOfflineMode {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger) {
        [adjustAPI ccPutSdkOffline];
    }];
}

+ (void)switchBackToOnlineMode {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger) {
        [adjustAPI ccPutSdkOnline];
    }];
}

#pragma mark Inactive/ Reactive SDK Methods
+ (void)inactivateSdk {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger) {
        [adjustAPI ccInactivateSdk];
    }];
}

+ (void)reactivateSdk {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger) {
        [adjustAPI ccReactivateSdk];
    }];
}

+ (void)trackLaunchedDeeplink:(nonnull ADJAdjustLaunchedDeeplink *)adjustLaunchedDeeplink {
    [ADJEntryRoot executeBlockInClientContext:
        ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
    {
        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
            [adjustAPI ccClientActionWithSource:@"trackLaunchedDeeplink"];

        if (clientActionsAPI == nil) {
            return;
        }

        ADJClientLaunchedDeeplinkData *_Nullable clientLaunchedDeeplinkData =
            [ADJClientLaunchedDeeplinkData
                 instanceFromClientWithAdjustLaunchedDeeplink:adjustLaunchedDeeplink
                 logger:apiLogger];

        if (clientLaunchedDeeplinkData == nil) {
            return;
        }

        [clientActionsAPI ccTrackLaunchedDeeplinkWithClientData:clientLaunchedDeeplinkData];
    }];
}

#pragma mark Track Event Method
+ (void)trackEvent:(nonnull ADJAdjustEvent *)adjustEvent {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger) {
        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [adjustAPI ccClientActionWithSource:@"trackEvent"];

        if (clientActionsAPI == nil) {
            return;
        }

        ADJClientEventData *_Nullable clientEventData =
        [ADJClientEventData instanceFromClientWithAdjustEvent:adjustEvent
                                                       logger:apiLogger];

        if (clientEventData == nil) {
            return;
        }

        [clientActionsAPI ccTrackEventWithClientData:clientEventData];
    }];
}

+ (void)trackPushToken:(nonnull ADJAdjustPushToken *)adjustPushToken {
    [ADJEntryRoot executeBlockInClientContext:
        ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
    {
        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
            [adjustAPI ccClientActionWithSource:@"trackPushToken"];

        if (clientActionsAPI == nil) {
            return;
        }

        ADJClientPushTokenData *_Nullable clientPushTokenData =
            [ADJClientPushTokenData instanceFromClientWithAdjustPushToken:adjustPushToken
                                                                    logger:apiLogger];

        if (clientPushTokenData == nil) {
            return;
        }

        [clientActionsAPI ccTrackPushTokenWithClientData:clientPushTokenData];
    }];
}

+ (void)trackThirdPartySharing:(nonnull ADJAdjustThirdPartySharing *)adjustThirdPartySharing {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
     {
        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [adjustAPI ccClientActionWithSource:@"trackThirdPartySharing"];

        if (clientActionsAPI == nil) {
            return;
        }

        ADJClientThirdPartySharingData *_Nullable clientThirdPartySharingData =
        [ADJClientThirdPartySharingData
         instanceFromClientWithAdjustThirdPartySharing:adjustThirdPartySharing
         logger:apiLogger];

        if (clientThirdPartySharingData == nil) {
            return;
        }

        [clientActionsAPI ccTrackThirdPartySharingWithClientData:clientThirdPartySharingData];
    }];
}

#pragma mark Lifecycle Methods
+ (void)appWentToTheForegroundManualCall {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
     {
        [adjustAPI ccForeground];
    }];

}

+ (void)appWentToTheBackgroundManualCall {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
     {
        [adjustAPI ccBackground];
    }];
}

+ (void)trackAdRevenue:(nonnull ADJAdjustAdRevenue *)adjustAdRevenue {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
     {
        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [adjustAPI ccClientActionWithSource:@"trackAdRevenue"];

        if (clientActionsAPI == nil) {
            return;
        }

        ADJClientAdRevenueData *_Nullable clientAdRevenueData = [ADJClientAdRevenueData
                                                                 instanceFromClientWithAdjustAdRevenue:adjustAdRevenue
                                                                 logger:apiLogger];

        if (clientAdRevenueData == nil) {
            return;
        }

        [clientActionsAPI ccTrackAdRevenueWithClientData:clientAdRevenueData];
    }];
}

+ (void)trackBillingSubscription:(nonnull ADJAdjustBillingSubscription *)adjustBillingSubscription {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
     {
        id<ADJClientActionsAPI> _Nullable clientActionsAPI =
        [adjustAPI ccClientActionWithSource:@"trackBillingSubscription"];
        
        if (clientActionsAPI == nil) {
            return;
        }
        
        ADJClientBillingSubscriptionData *_Nullable clientBillingSubscriptionData =
        [ADJClientBillingSubscriptionData
         instanceFromClientWithAdjustBillingSubscription:adjustBillingSubscription
         logger:apiLogger];
        
        if (clientBillingSubscriptionData == nil) {
            return;
        }
        
        [clientActionsAPI
         ccTrackBillingSubscriptionWithClientData:clientBillingSubscriptionData];
    }];
}

+ (void)adjustAttributionWithCallback:(nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback {
    [ADJEntryRoot executeBlockInClientContext:
        ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
    {
        if (adjustAttributionCallback == nil) {
            [apiLogger error:@"Cannot get Adjust Attribution with nil callback"];
            return;
        }

        [adjustAPI ccAttributionWithCallback:adjustAttributionCallback];
    }];
}

+ (void)deviceIdsWithCallback:(nonnull id<ADJAdjustDeviceIdsCallback>)adjustDeviceIdsCallback {
    [ADJEntryRoot executeBlockInClientContext:
        ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
    {
        if (adjustDeviceIdsCallback == nil) {
            [apiLogger error:@"Cannot get Adjust Device Ids with nil callback"];
            return;
        }

        [adjustAPI ccDeviceIdsWithCallback:adjustDeviceIdsCallback];
    }];
}

#pragma mark Global Parameters Methods

+ (void)addGlobalCallbackParameterWithKey:(nonnull NSString *)key
                                    value:(nonnull NSString *)value {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger) {
        id<ADJClientActionsAPI> _Nullable clientActionsAPI = [adjustAPI ccClientActionWithSource:@"addGlobalCallbackParameter"];

        if (clientActionsAPI == nil) {
            return;
        }

        ADJClientAddGlobalParameterData *_Nullable clientAddGlobalParameterData = [ADJClientAddGlobalParameterData
                                                                                   instanceFromClientWithAdjustConfigWithKeyToAdd:key
                                                                                   valueToAdd:value
                                                                                   logger:apiLogger];

        if (clientAddGlobalParameterData == nil) {
            return;
        }

        [clientActionsAPI ccAddGlobalCallbackParameterWithClientData:clientAddGlobalParameterData];
    }];
}

+ (void)removeGlobalCallbackParameterByKey:(nonnull NSString *)key {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger) {
        id<ADJClientActionsAPI> _Nullable clientActionsAPI = [adjustAPI ccClientActionWithSource:@"removeGlobalCallbackParameter"];

        if (clientActionsAPI == nil) {
            return;
        }

        ADJClientRemoveGlobalParameterData *_Nullable clientRemoveGlobalParameterData = [ADJClientRemoveGlobalParameterData
                                                                                         instanceFromClientWithAdjustConfigWithKeyToRemove:key
                                                                                         logger:apiLogger];

        if (clientRemoveGlobalParameterData == nil) {
            return;
        }

        [clientActionsAPI ccRemoveGlobalCallbackParameterWithClientData:clientRemoveGlobalParameterData];
    }];
}

+ (void)clearAllGlobalCallbackParameters {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
     {
        id<ADJClientActionsAPI> _Nullable clientActionsAPI = [adjustAPI ccClientActionWithSource:@"clearAllGlobalCallbackParameters"];

        if (clientActionsAPI == nil) {
            return;
        }

        ADJClientClearGlobalParametersData *_Nonnull clientClearGlobalParametersData = [[ADJClientClearGlobalParametersData alloc] init];

        [clientActionsAPI ccClearGlobalCallbackParametersWithClientData:clientClearGlobalParametersData];
    }];
}

+ (void)addGlobalPartnerParameterWithKey:(nonnull NSString *)key
                                   value:(nonnull NSString *)value {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
     {
        id<ADJClientActionsAPI> _Nullable clientActionsAPI = [adjustAPI ccClientActionWithSource:@"addGlobalPartnerParameter"];

        if (clientActionsAPI == nil) {
            return;
        }

        ADJClientAddGlobalParameterData *_Nullable clientAddGlobalParameterData = [ADJClientAddGlobalParameterData
                                                                                   instanceFromClientWithAdjustConfigWithKeyToAdd:key
                                                                                   valueToAdd:value
                                                                                   logger:apiLogger];

        if (clientAddGlobalParameterData == nil) {
            return;
        }

        [clientActionsAPI ccAddGlobalPartnerParameterWithClientData:clientAddGlobalParameterData];
    }];
}

+ (void)removeGlobalPartnerParameterByKey:(nonnull NSString *)key {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
     {
        id<ADJClientActionsAPI> _Nullable clientActionsAPI = [adjustAPI ccClientActionWithSource:@"removeGlobalPartnerParameter"];

        if (clientActionsAPI == nil) {
            return;
        }

        ADJClientRemoveGlobalParameterData *_Nullable clientRemoveGlobalParameterData = [ADJClientRemoveGlobalParameterData
                                                                                         instanceFromClientWithAdjustConfigWithKeyToRemove:key
                                                                                         logger:apiLogger];

        if (clientRemoveGlobalParameterData == nil) {
            return;
        }

        [clientActionsAPI ccRemoveGlobalPartnerParameterWithClientData:clientRemoveGlobalParameterData];
    }];
}

+ (void)clearAllGlobalPartnerParameters {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
     {
        id<ADJClientActionsAPI> _Nullable clientActionsAPI = [adjustAPI ccClientActionWithSource:@"clearAllGlobalPartnerParameters"];

        if (clientActionsAPI == nil) {
            return;
        }

        ADJClientClearGlobalParametersData *_Nonnull clientClearGlobalParametersData = [[ADJClientClearGlobalParametersData alloc] init];

        [clientActionsAPI ccClearGlobalPartnerParametersWithClientData:clientClearGlobalParametersData];
    }];
}

+ (void)gdprForgetDevice {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
     {
        [adjustAPI ccGdprForgetDevice];
    }];
}

@end


