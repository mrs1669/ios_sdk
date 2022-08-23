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

        ADJClientAdRevenueData *_Nullable clientAdRevenueData = [ADJClientAdRevenueData instanceFromClientWithAdjustAdRevenue:adjustAdRevenue
                                                                                                                       logger:apiLogger];

        if (clientAdRevenueData == nil) {
            return;
        }

        [clientActionsAPI ccTrackAdRevenueWithClientData:clientAdRevenueData];
    }];
}


@end
