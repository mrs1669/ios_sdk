//
//  ADJClientCallbacksController.m
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientCallbacksController.h"

#import "ADJSessionDeviceIdsData.h"
#import "ADJUtilF.h"
#import "ADJConsoleLogger.h"
#import "ADJAdjustLogMessageData.h"
#import "ADJClientLaunchedDeeplinkData.h"

@interface ADJClientCallbacksController ()
@end

@implementation ADJClientCallbacksController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"ClientCallbacksController"];

    return self;
}

#pragma mark Public API
- (void)failWithAdjustCallback:(nullable id<ADJAdjustCallback>)adjustCallback
          clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
             cannotPerformFail:(nonnull ADJResultFail *)cannotPerformFail
                          from:(nonnull NSString *)from
{
    ADJOptionalFailsNN<NSString *> *_Nonnull cannotPerformMessageOptFails =
        [ADJUtilJson toStringFromDictionary:[cannotPerformFail toJsonDictionary]];
    for (ADJResultFail *_Nonnull optFail in cannotPerformMessageOptFails.optionalFails) {
        [self.logger debugDev:@"Could not parse json dictionary"
                         from:from
                   resultFail:optFail
                    issueType:ADJIssueLogicError];
    }

    [clientReturnExecutor executeClientReturnWithBlock:^{
        [adjustCallback didFailWithAdjustCallbackMessage:cannotPerformMessageOptFails.value];
    }];
}

- (void)ccAttributionWithCallback:(nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback
             clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
          attributionStateStorage:(nonnull ADJAttributionStateStorage *)attributionStateStorage
{
    ADJAttributionStateData *_Nonnull attributionStateData =
    [attributionStateStorage readOnlyStoredDataValue];
    ADJAttributionData *_Nullable attributionData = attributionStateData.attributionData;

    if (attributionData != nil) {
        [self.logger debugDev:@"Returning attribution data to client in callback"];

        ADJAdjustAttribution *_Nonnull adjustAttribution = [attributionData toAdjustAttribution];

        [clientReturnExecutor executeClientReturnWithBlock:^{
            [adjustAttributionCallback didReadWithAdjustAttribution:adjustAttribution];
        }];
        return;
    }

    if ([attributionStateData unavailableStatus]) {
        [self.logger debugDev:@"Returning fail on client attribution callback"
         " because it is not available from the backend"];
        [clientReturnExecutor executeClientReturnWithBlock:^{
            [adjustAttributionCallback didFailWithAdjustCallbackMessage:
             @"Cannot read attribution data because it is not available from the backend"];
        }];
    } else {
        [self.logger debugDev:@"Returning fail on client attribution callback"
         " because it still waiting"];
        [clientReturnExecutor executeClientReturnWithBlock:^{
            [adjustAttributionCallback didFailWithAdjustCallbackMessage:
             @"Cannot read attribution data because it still waiting."
             " Please try again later or subscribe for attribution at sdk init"];
        }];
    }
}

- (void)ccLaunchedDeepLinkWithCallback:(nonnull id<ADJAdjustLaunchedDeeplinkCallback>)adjustLaunchedDeeplinkCallback
                  clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
          LaunchedDeeplinkStateStorage:(nonnull ADJLaunchedDeeplinkStateStorage *)launchedDeeplinkStateStorage
{
    ADJLaunchedDeeplinkStateData *_Nonnull launchedDeeplinkStateData =
    [launchedDeeplinkStateStorage readOnlyStoredDataValue];

    if (launchedDeeplinkStateData.launchedDeeplink != nil) {
        [self.logger debugDev:@"Returning launched deeplink data to client in callback"];

        [clientReturnExecutor executeClientReturnWithBlock:^{
            [adjustLaunchedDeeplinkCallback
             didReadWithAdjustLaunchedDeeplink:launchedDeeplinkStateData.launchedDeeplink.stringValue];
        }];
    } else {

        [self.logger debugDev:@"Cannot get launched deeplink for callback"];
        [clientReturnExecutor executeClientReturnWithBlock:^{
            [adjustLaunchedDeeplinkCallback
             didFailWithAdjustCallbackMessage:@"Cannot get launched deeplink data because it is not available"];
        }];
    }
}

- (void)ccDeviceIdsWithCallback:(nonnull id<ADJAdjustDeviceIdsCallback>)adjustDeviceIdsCallback
           clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
               deviceController:(nonnull ADJDeviceController *)deviceController
{
    ADJResult<ADJSessionDeviceIdsData *> *_Nonnull sessionDeviceIdsDataResult =
        [deviceController getSessionDeviceIdsSync];

    if (sessionDeviceIdsDataResult.fail != nil) {
        ADJInputLogMessageData *_Nonnull inputLog =
            [self.logger noticeClient:@"Cannot get device ids for callback"
                           resultFail:sessionDeviceIdsDataResult.fail];

        NSString *_Nonnull callbackFailMessage =
            [ADJConsoleLogger clientCallbackFormatMessageWithLog:inputLog];

        [clientReturnExecutor executeClientReturnWithBlock:^{
            [adjustDeviceIdsCallback didFailWithAdjustCallbackMessage:callbackFailMessage];
        }];
        return;
    }

    ADJAdjustDeviceIds *_Nonnull adjustDeviceIds =
        [sessionDeviceIdsDataResult.value toAdjustDeviceIds];
    [clientReturnExecutor executeClientReturnWithBlock:^{
        [adjustDeviceIdsCallback didReadWithAdjustDeviceIds:adjustDeviceIds];
    }];
}

@end
