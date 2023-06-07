//
//  ADJGlobalPartnerParametersController.h
//  Adjust
//
//  Created by Aditi Agrawal on 25/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJGlobalParametersControllerBase.h"
#import "ADJGlobalPartnerParametersStorage.h"
#import "ADJClientAddGlobalParameterData.h"
#import "ADJClientRemoveGlobalParameterData.h"
#import "ADJClientClearGlobalParametersData.h"
#import "ADJStringMap.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJGlobalPartnerParametersControllerClientActionHandlerId;
FOUNDATION_EXPORT NSString *const ADJGlobalParametersTypePartner;

NS_ASSUME_NONNULL_END

@interface ADJGlobalPartnerParametersController : ADJGlobalParametersControllerBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                      storage:(nonnull ADJGlobalPartnerParametersStorage *)storage;

// public api
- (void)ccAddGlobalPartnerParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalParameterData;

- (void)ccRemoveGlobalPartnerParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalParameterData;

- (void)ccClearGlobalPartnerParameterWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalParametersData;

- (nonnull ADJStringMap *)currentGlobalPartnerParameters;

@end
