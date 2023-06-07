//
//  ADJGlobalCallbackParametersController.h
//  Adjust
//
//  Created by Aditi Agrawal on 25/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJGlobalParametersControllerBase.h"
#import "ADJGlobalCallbackParametersStorage.h"
#import "ADJClientAddGlobalParameterData.h"
#import "ADJClientRemoveGlobalParameterData.h"
#import "ADJClientClearGlobalParametersData.h"
#import "ADJStringMap.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJGlobalCallbackParametersControllerClientActionHandlerId;
FOUNDATION_EXPORT NSString *const ADJGlobalParametersTypeCallback;

NS_ASSUME_NONNULL_END

@interface ADJGlobalCallbackParametersController : ADJGlobalParametersControllerBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                      storage:(nonnull ADJGlobalCallbackParametersStorage *)storage;

// public api
- (void)ccAddGlobalCallbackParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalParameterData;

- (void)ccRemoveGlobalCallbackParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalParameterData;

- (void)ccClearGlobalCallbackParameterWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalParametersData;

- (nonnull ADJStringMap *)currentGlobalCallbackParameters;

@end

