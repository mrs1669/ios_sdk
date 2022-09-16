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
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                      attributionStateStorage:(nonnull ADJAttributionStateStorage *)attributionStateStorage
                         clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
                             deviceController:(nonnull ADJDeviceController *)deviceController;

// public api
- (void)ccAttributionWithCallback:(nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback;

//- (void)ccDeviceIdsWithCallback:
//    (nonnull id<ADJAdjustDeviceIdsCallback>)adjustDeviceIdsCallback;

@end
