//
//  ADJGlobalParametersControllerBase.h
//  Adjust
//
//  Created by Aditi Agrawal on 25/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJClientActionHandler.h"
#import "ADJSQLiteStorageStringMapBase.h"
#import "ADJSQLiteStorageActionBase.h"
#import "ADJClientAddGlobalParameterData.h"
#import "ADJClientRemoveGlobalParameterData.h"
#import "ADJClientClearGlobalParametersData.h"
#import "ADJTimestampMilli.h"
#import "ADJStringMap.h"

@interface ADJGlobalParametersControllerBase : ADJCommonBase<ADJClientActionHandler>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                       source:(nonnull NSString *)source
                         globalParametersType:(nonnull NSString *)globalParametersType
                   sqliteStorageStringMapBase:(nonnull ADJSQLiteStorageStringMapBase *)sqliteStorageStringMapBase;

// protected
@property (nonnull, readonly, strong, nonatomic) ADJStringMap *cachedGlobalParameters;

- (BOOL)ccAddGlobalParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalParameterData
                              apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
       clientActionRemoveStorageActionData:(nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageActionData;

- (BOOL)ccRemoveGlobalParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalParameterData
                                 apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
          clientActionRemoveStorageActionData:(nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageActionData;

- (BOOL)ccClearGlobalParameterWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalParametersData
                                apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
         clientActionRemoveStorageActionData:(nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageActionData;
@end
