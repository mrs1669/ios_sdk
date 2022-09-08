//
//  ADJAdjust.m
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//

#import "ADJAdjust.h"
#import "ADJEntryRoot.h"
#import "ADJClientConfigData.h"

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
        ADJClientConfigData *_Nullable clientConfigData = [ADJClientConfigData
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
            [adjustAPI ccClientActionsWithSource:@"trackLaunchedDeeplink"];

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
        [adjustAPI ccClientActionsWithSource:@"trackEvent"];

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
            [adjustAPI ccClientActionsWithSource:@"trackPushToken"];

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
        [adjustAPI ccClientActionsWithSource:@"trackAdRevenue"];

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

#pragma mark Global Parameters Methods

+ (void)addGlobalCallbackParameterWithKey:(nonnull NSString *)key
                                    value:(nonnull NSString *)value {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger) {
        id<ADJClientActionsAPI> _Nullable clientActionsAPI = [adjustAPI ccClientActionsWithSource:@"addGlobalCallbackParameter"];

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
        id<ADJClientActionsAPI> _Nullable clientActionsAPI = [adjustAPI ccClientActionsWithSource:@"removeGlobalCallbackParameter"];

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
        id<ADJClientActionsAPI> _Nullable clientActionsAPI = [adjustAPI ccClientActionsWithSource:@"clearAllGlobalCallbackParameters"];

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
        id<ADJClientActionsAPI> _Nullable clientActionsAPI = [adjustAPI ccClientActionsWithSource:@"addGlobalPartnerParameter"];

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
        id<ADJClientActionsAPI> _Nullable clientActionsAPI = [adjustAPI ccClientActionsWithSource:@"removeGlobalPartnerParameter"];

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
        id<ADJClientActionsAPI> _Nullable clientActionsAPI = [adjustAPI ccClientActionsWithSource:@"clearAllGlobalPartnerParameters"];

        if (clientActionsAPI == nil) {
            return;
        }

        ADJClientClearGlobalParametersData *_Nonnull clientClearGlobalParametersData = [[ADJClientClearGlobalParametersData alloc] init];

        [clientActionsAPI ccClearGlobalPartnerParametersWithClientData:clientClearGlobalParametersData];
    }];
}

@end


