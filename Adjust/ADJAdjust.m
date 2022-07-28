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

#pragma mark Public API
+ (void)sdkInitWithAdjustConfig:(nonnull ADJAdjustConfig *)adjustConfig {
    [ADJEntryRoot executeBlockInClientContext:
     ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
     {
        ADJClientConfigData *_Nullable clientConfigData =
        [ADJClientConfigData instanceFromClientWithAdjustConfig:adjustConfig
                                                         logger:apiLogger];
        
        if (clientConfigData == nil) {
            [apiLogger error:@"Cannot init SDK without valid adjust config"];
            return;
        }
        
        [adjustAPI ccSdkInitWithClientConfigData:clientConfigData];
    }];
}

//+ (void)inactivateSdk {
//    [ADJEntryRoot executeBlockInClientContext:
//        ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
//    {
//        [adjustAPI ccInactivateSdk];
//    }];
//}
//
//+ (void)reactivateSdk {
//    [ADJEntryRoot executeBlockInClientContext:
//        ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
//    {
//        [adjustAPI ccReactivateSdk];
//    }];
//}


+ (void)trackEvent:(nonnull ADJAdjustEvent *)adjustEvent {
    [ADJEntryRoot executeBlockInClientContext:
        ^(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger)
    {
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


@end
