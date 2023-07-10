//
//  ADJClientCallbacksController.h
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJCommonBase.h"
#import "ADJAttributionStateStorage.h"
#import "ADJClientReturnExecutor.h"
#import "ADJAdjustAttributionCallback.h"
#import "ADJAdjustDeviceIdsCallback.h"
#import "ADJAdjustIdentifierCallback.h"
#import "ADJAdjustLaunchedDeeplinkCallback.h"
#import "ADJAdidStateStorage.h"
#import "ADJLaunchedDeeplinkStateStorage.h"
#import "ADJDeviceController.h"
#import "ADJAdjustCallback.h"
#import "ADJAdjustInternal.h"

@interface ADJClientCallbacksController : ADJCommonBase
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor;

// public api
- (void)failWithAdjustCallback:(nonnull id<ADJAdjustCallback>)adjustCallback
             cannotPerformFail:(nonnull ADJResultFail *)cannotPerformFail
                          from:(nonnull NSString *)from;

- (void)failWithInternalCallback:(nonnull id<ADJInternalCallback>)internalCallback
                  failMethodName:(nonnull NSString *)failMethodName
               cannotPerformFail:(nonnull ADJResultFail *)cannotPerformFail
                            from:(nonnull NSString *)from;

- (void)
    ccAttributionWithCallback:
        (nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback
    attributionStateReadOnlyStorage:
        (nonnull ADJAttributionStateStorage *)attributionStateReadOnlyStorage;
- (void)
    ccAttributionWithInternalCallback:
        (nonnull id<ADJInternalCallback>)internalCallback
    attributionStateReadOnlyStorage:
        (nonnull ADJAttributionStateStorage *)attributionStateReadOnlyStorage;

- (void)
    ccAdidWithAdjustCallback:(nonnull id<ADJAdjustIdentifierCallback>)adjustIdentifierCallback
    adidStateReadOnlyStorage:(nonnull ADJAdidStateStorage *)adidStateReadOnlyStorage;

- (void)
    ccDeviceIdsWithAdjustCallback:(nonnull id<ADJAdjustDeviceIdsCallback>)adjustDeviceIdsCallback
    deviceController:(nonnull ADJDeviceController *)deviceController;
- (void)ccDeviceIdsWithInternalCallback:(nonnull id<ADJInternalCallback>)internalCallback
               deviceController:(nonnull ADJDeviceController *)deviceController;

- (void)
    ccLaunchedDeepLinkWithCallback:
        (nonnull id<ADJAdjustLaunchedDeeplinkCallback>)adjustLaunchedDeeplinkCallback
    clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
    LaunchedDeeplinkStateStorage:
        (nonnull ADJLaunchedDeeplinkStateStorage *)launchedDeeplinkStateStorage;

@end

