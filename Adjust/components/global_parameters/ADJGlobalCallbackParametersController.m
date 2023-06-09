//
//  ADJGlobalCallbackParametersController.m
//  Adjust
//
//  Created by Aditi Agrawal on 25/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGlobalCallbackParametersController.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJGlobalCallbackParametersControllerClientActionHandlerId = @"GlobalCallbackParametersController";
NSString *const ADJGlobalParametersTypeCallback = @"callback";

@implementation ADJGlobalCallbackParametersController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                      storage:(nonnull ADJGlobalCallbackParametersStorage *)storage {
    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:@"GlobalCallbackParametersController"
                   globalParametersType:ADJGlobalParametersTypeCallback
             sqliteStorageStringMapBase:storage];

    return self;
}

#pragma mark Public API
- (void)ccAddGlobalCallbackParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalParameterData {
    [self ccAddGlobalParameterWithClientData:clientAddGlobalParameterData
                                apiTimestamp:nil
         clientActionRemoveStorageActionData:nil];
}

- (void)ccRemoveGlobalCallbackParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalParameterData {
    [self ccRemoveGlobalParameterWithClientData:clientRemoveGlobalParameterData
                                   apiTimestamp:nil
            clientActionRemoveStorageActionData:nil];
}

- (void)ccClearGlobalCallbackParameterWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalParametersData {
    [self ccClearGlobalParameterWithClientData:clientClearGlobalParametersData
                                  apiTimestamp:nil
           clientActionRemoveStorageActionData:nil];
}

- (nonnull ADJStringMap *)currentGlobalCallbackParameters {
    return [self cachedGlobalParameters];
}

@end

