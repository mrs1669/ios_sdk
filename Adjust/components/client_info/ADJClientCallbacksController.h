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
#import "ADJDeviceController.h"

@interface ADJClientCallbacksController : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory;

// public api
- (void)failWithAdjustCallback:(nullable id<ADJAdjustCallback>)adjustCallback
          clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
          cannotPerformMessage:(nonnull NSString *)cannotPerformMessage;

- (void)
    ccAttributionWithCallback:
        (nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback
    clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
    attributionStateStorage:(nonnull ADJAttributionStateStorage *)attributionStateStorage;

- (void)ccDeviceIdsWithCallback:(nonnull id<ADJAdjustDeviceIdsCallback>)adjustDeviceIdsCallback
           clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
               deviceController:(nonnull ADJDeviceController *)deviceController;

@end
