//
//  ADJGlobalPartnerParametersController.m
//  Adjust
//
//  Created by Aditi Agrawal on 25/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGlobalPartnerParametersController.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJGlobalPartnerParametersControllerClientActionHandlerId = @"GlobalPartnerParametersController";
NSString *const ADJGlobalParametersTypePartner = @"partner";

@implementation ADJGlobalPartnerParametersController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                      storage:(nonnull ADJGlobalPartnerParametersStorage *)storage {
    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:@"GlobalPartnerParametersController"
                   globalParametersType:ADJGlobalParametersTypePartner
             sqliteStorageStringMapBase:storage];

    return self;
}

// public api
- (void)ccAddGlobalPartnerParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalParameterData {
    [self ccAddGlobalParameterWithClientData:clientAddGlobalParameterData
                                apiTimestamp:nil
         clientActionRemoveStorageActionData:nil];
}

- (void)ccRemoveGlobalPartnerParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalParameterData {
    [self ccRemoveGlobalParameterWithClientData:clientRemoveGlobalParameterData
                                   apiTimestamp:nil
            clientActionRemoveStorageActionData:nil];
}

- (void)ccClearGlobalPartnerParameterWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalParametersData {
    [self ccClearGlobalParameterWithClientData:clientClearGlobalParametersData
                                  apiTimestamp:nil
           clientActionRemoveStorageActionData:nil];
}

- (nonnull ADJStringMap *)currentGlobalPartnerParameters {
    return [self cachedGlobalParameters];
}

@end

