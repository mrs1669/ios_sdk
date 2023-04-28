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
#pragma mark - Injected dependencies
@property (nullable, readonly, strong, nonatomic) id<ADJClientReturnExecutor> clientReturnExecutor;

@end

@implementation ADJClientCallbacksController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"ClientCallbacksController"];
    _clientReturnExecutor = clientReturnExecutor;

    return self;
}

#pragma mark Public API
- (void)failWithAdjustCallback:(nonnull id<ADJAdjustCallback>)adjustCallback
             cannotPerformFail:(nonnull ADJResultFail *)cannotPerformFail
                          from:(nonnull NSString *)from
{
    __block NSString *_Nonnull cannotPerformMessage =
        [self cannotPerformMessageWithFail:cannotPerformFail from:from];

    [self.clientReturnExecutor executeClientReturnWithBlock:^{
        [adjustCallback didFailWithAdjustCallbackMessage:cannotPerformMessage];
    }];
}
- (void)failWithInternalCallback:(nonnull id<ADJInternalCallback>)internalCallback
                  failMethodName:(nonnull NSString *)failMethodName
               cannotPerformFail:(nonnull ADJResultFail *)cannotPerformFail
                            from:(nonnull NSString *)from
{
    __block NSString *_Nonnull cannotPerformMessage =
        [self cannotPerformMessageWithFail:cannotPerformFail from:from];

    __block NSDictionary<NSString *, id> *_Nonnull callbackData =
        [NSDictionary dictionaryWithObjectsAndKeys:cannotPerformMessage, failMethodName, nil];

    [self.clientReturnExecutor executeClientReturnWithBlock:^{
        [internalCallback didInternalCallbackWithData:callbackData];
    }];
}
- (nonnull NSString *)cannotPerformMessageWithFail:(nonnull ADJResultFail *)cannotPerformFail
                                              from:(nonnull NSString *)from
{
    ADJOptionalFailsNN<NSString *> *_Nonnull cannotPerformMessageOptFails =
        [ADJUtilJson toStringFromDictionary:[cannotPerformFail toJsonDictionary]];
    for (ADJResultFail *_Nonnull optFail in cannotPerformMessageOptFails.optionalFails) {
        [self.logger debugDev:@"Could not parse json dictionary of fail"
                         from:from
                   resultFail:optFail
                    issueType:ADJIssueLogicError];
    }

    return cannotPerformMessageOptFails.value;
}

- (void)
    ccAttributionWithCallback:
        (nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback
    attributionStateReadOnlyStorage:
        (nonnull ADJAttributionStateStorage *)attributionStateReadOnlyStorage
{
    [self ccAttributionWithAdjustCallback:adjustAttributionCallback
                         internalCallback:nil
          attributionStateReadOnlyStorage:attributionStateReadOnlyStorage];
}
- (void)
    ccAttributionWithInternalCallback:
        (nonnull id<ADJInternalCallback>)internalCallback
    attributionStateReadOnlyStorage:
        (nonnull ADJAttributionStateStorage *)attributionStateReadOnlyStorage
{
    [self ccAttributionWithAdjustCallback:nil
                         internalCallback:internalCallback
          attributionStateReadOnlyStorage:attributionStateReadOnlyStorage];
}
- (void)
    ccAttributionWithAdjustCallback:
        (nullable id<ADJAdjustAttributionCallback>)adjustCallback
    internalCallback:(nullable id<ADJInternalCallback>)internalCallback
    attributionStateReadOnlyStorage:
        (nonnull ADJAttributionStateStorage *)attributionStateReadOnlyStorage
{
    ADJAttributionStateData *_Nonnull attributionStateData =
        [attributionStateReadOnlyStorage readOnlyStoredDataValue];
    ADJAttributionData *_Nullable attributionData = attributionStateData.attributionData;

    if (attributionData != nil) {
        [self.logger debugDev:@"Returning attribution data to client in callback"];

        ADJAdjustAttribution *_Nonnull adjustAttribution = [attributionData toAdjustAttribution];

        if (adjustCallback != nil) {
            [self.clientReturnExecutor executeClientReturnWithBlock:^{
                [adjustCallback didReadWithAdjustAttribution:adjustAttribution];
            }];
        }

        if (internalCallback != nil) {
            ADJOptionalFailsNN<NSDictionary<NSString *, id> *> *_Nonnull callbackDataOptFails =
                [attributionData
                 buildInternalCallbackDataWithMethodName:ADJAttributionGetterReadMethodName];

            __block NSDictionary<NSString *, id> *_Nonnull callbackData =
                callbackDataOptFails.value;
            [self.clientReturnExecutor executeClientReturnWithBlock:^{
                [internalCallback didInternalCallbackWithData:callbackData];
            }];
        }

        return;
    }

    NSString *_Nonnull clientFailMessage;
    if ([attributionStateData unavailableStatus]) {
        [self.logger debugDev:@"Returning fail on client attribution callback"
         " because it is not available from the backend"];
        clientFailMessage =
            @"Cannot read attribution data because it is not available from the backend";
    } else {
        [self.logger debugDev:@"Returning fail on client attribution callback"
         " because it still waiting"];
        clientFailMessage = @"Cannot read attribution data because it still waiting."
            " Please try again later or subscribe for attribution at sdk init";
    }

    if (adjustCallback != nil) {
        [self.clientReturnExecutor executeClientReturnWithBlock:^{
            [adjustCallback didFailWithAdjustCallbackMessage:clientFailMessage];
        }];
    }

    if (internalCallback != nil) {
        __block NSDictionary<NSString *, id> *_Nonnull callbackData =
            [NSDictionary dictionaryWithObjectsAndKeys:
             clientFailMessage, ADJAttributionGetterFailedMethodName, nil];
        [self.clientReturnExecutor executeClientReturnWithBlock:^{
            [internalCallback didInternalCallbackWithData:callbackData];
        }];
    }
}

- (void)
    ccLaunchedDeepLinkWithCallback:
        (nonnull id<ADJAdjustLaunchedDeeplinkCallback>)adjustLaunchedDeeplinkCallback
    clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
    LaunchedDeeplinkStateStorage:
        (nonnull ADJLaunchedDeeplinkStateStorage *)launchedDeeplinkStateStorage
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
