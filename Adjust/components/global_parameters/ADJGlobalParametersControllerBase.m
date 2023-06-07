//
//  ADJGlobalParametersControllerBase.m
//  Adjust
//
//  Created by Aditi Agrawal on 25/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGlobalParametersControllerBase.h"

#import "ADJUtilSys.h"
#import "ADJClientActionData.h"
#import "ADJUtilF.h"

@interface ADJGlobalParametersControllerBase ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJSQLiteStorageStringMapBase *sqliteStorageStringMapBaseWeak;
@property (nonnull, readonly, strong, nonatomic) NSString *globalParametersType;

@end

@implementation ADJGlobalParametersControllerBase
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                       source:(nonnull NSString *)source
                         globalParametersType:(nonnull NSString *)globalParametersType
                   sqliteStorageStringMapBase:(nonnull ADJSQLiteStorageStringMapBase *)sqliteStorageStringMapBase {
    // prevents direct creation of instance, needs to be invoked by subclass
    if ([self isMemberOfClass:[ADJGlobalParametersControllerBase class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }

    self = [super initWithLoggerFactory:loggerFactory
                                 source:source];

    _sqliteStorageStringMapBaseWeak = sqliteStorageStringMapBase;

    _globalParametersType = globalParametersType;

    return self;
}

+ (nonnull ADJOptionalFailsNL<ADJStringMap *> *)
    paramsInstanceFromV4WithSessionParameters:
        (nullable NSDictionary<NSString *, NSString *> *)sessionParameters
{
    if (sessionParameters == nil) {
        return [[ADJOptionalFailsNL alloc] initWithOptionalFails:nil value:nil];
    }

    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut = [[NSMutableArray alloc] init];
    ADJStringMapBuilder *_Nonnull sessionParametersBuilder =
        [[ADJStringMapBuilder alloc] initWithEmptyMap];

    for (NSString *_Nonnull key in sessionParameters) {
        ADJResultNN<ADJNonEmptyString *> *_Nonnull keyResult =
            [ADJNonEmptyString instanceFromString:key];
        if (keyResult.fail != nil) {
            [optionalFailsMut addObject:[[ADJResultFail alloc]
                                         initWithMessage:@"Invalid session parameter key"
                                         key:@"key parsing fail"
                                         otherFail:keyResult.fail]];
            continue;
        }

        ADJResultNN<ADJNonEmptyString *> *_Nonnull valueResult =
            [ADJNonEmptyString instanceFromString:[sessionParameters objectForKey:key]];
        if (valueResult.fail != nil) {
            [optionalFailsMut addObject:[[ADJResultFail alloc]
                                         initWithMessage:@"Invalid session parameter value"
                                         key:@"value parsing fail"
                                         otherFail:valueResult.fail]];
            continue;
        }

        [sessionParametersBuilder addPairWithValue:valueResult.value
                                               key:keyResult.value.stringValue];
    }

    if ([sessionParametersBuilder countPairs] == 0) {
        return [[ADJOptionalFailsNL alloc]
                initWithOptionalFails:optionalFailsMut
                value:nil];
    }

    return [[ADJOptionalFailsNL alloc]
            initWithOptionalFails:optionalFailsMut
            value:[[ADJStringMap alloc] initWithStringMapBuilder:sessionParametersBuilder]];
}

#pragma mark Public API
#pragma mark - ADJClientActionHandler
- (BOOL)ccCanHandlePreFirstSessionClientAction {
    return YES;
}

- (void)ccHandleClientActionWithIoInjectedData:(nonnull ADJIoData *)clientActionIoInjectedData
                                  apiTimestamp:(nonnull ADJTimestampMilli *)apiTimestamp
                           removeStorageAction:(nonnull ADJSQLiteStorageActionBase *)removeStorageAction {
    BOOL handled = [self ccTryHandleClientActionWithClientActionIoInjectedData:clientActionIoInjectedData
                                                                  apiTimestamp:apiTimestamp
                                               clientActionRemoveStorageAction:removeStorageAction];

    if (! handled) {
        [ADJUtilSys finalizeAtRuntime:removeStorageAction];
    }
}

#pragma mark Protected Methods
- (BOOL)ccAddGlobalParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalParameterData
                              apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
       clientActionRemoveStorageActionData:(nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageActionData {
    ADJSQLiteStorageStringMapBase *storage = self.sqliteStorageStringMapBaseWeak;

    if (storage == nil) {
        [self.logger debugDev:@"Cannot add global parameter without a reference to storage"
                          key:@"parameter type"
                        value:self.globalParametersType
                    issueType:ADJIssueWeakReference];
        return NO;
    }

    ADJNonEmptyString *_Nullable previousValueBeforeAdding =
    [storage pairValueWithKey:clientAddGlobalParameterData.keyToAdd];

    if ([clientAddGlobalParameterData.valueToAdd isEqual:previousValueBeforeAdding]) {
        [self.logger noticeClient:
         @"Cannot add global parameter since the same key/value is already present"
                              key:@"parameter type"
                            value:self.globalParametersType];
        return NO;
    }

    [storage addPairWithValue:clientAddGlobalParameterData.valueToAdd
                          key:clientAddGlobalParameterData.keyToAdd
          sqliteStorageAction:clientActionRemoveStorageActionData];

    if (previousValueBeforeAdding != nil) {
        [self.logger infoClient:
         @"Added global parameter with key already present, value will be overwritten"
                            key:@"parameter type"
                          value:self.globalParametersType];
    } else {
        [self.logger infoClient:@"Added global parameter"
                            key:@"parameter type"
                          value:self.globalParametersType];
    }

    return YES;
}

- (BOOL)ccRemoveGlobalParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalParameterData
                                 apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
          clientActionRemoveStorageActionData:(nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageActionData {
    ADJSQLiteStorageStringMapBase *storage = self.sqliteStorageStringMapBaseWeak;

    if (storage == nil) {
        [self.logger debugDev:@"Cannot remove global parameter without a reference to storage"
                          key:@"parameter type"
                        value:self.globalParametersType
                    issueType:ADJIssueWeakReference];
        return NO;
    }

    ADJNonEmptyString *_Nullable removedValue =
    [storage removePairWithKey:clientRemoveGlobalParameterData.keyToRemove
           sqliteStorageAction:clientActionRemoveStorageActionData];

    if (removedValue != nil) {
        [self.logger infoClient:@"Removed global parameter"
                            key:@"parameter type"
                          value:self.globalParametersType];
    } else {
        [self.logger noticeClient:@"Cannot remove global parameter without key being present"
                              key:@"parameter type"
                            value:self.globalParametersType];
    }

    return YES;
}

- (BOOL)ccClearGlobalParameterWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalParametersData
                                apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
         clientActionRemoveStorageActionData:(nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageActionData {
    ADJSQLiteStorageStringMapBase *storage = self.sqliteStorageStringMapBaseWeak;

    if (storage == nil) {
        [self.logger debugDev:@"Cannot clear global parameters without a reference to storage"
                          key:@"parameter type"
                        value:self.globalParametersType];
        return NO;
    }

    NSUInteger clearedKeys =
    [storage removeAllPairsWithSqliteStorageAction:clientActionRemoveStorageActionData];

    [self.logger infoClient:@"Cleared %@ global %@ parameters"
                       key1:@"cleared values count"
                     value1:[ADJUtilF uIntegerFormat:clearedKeys].description
                       key2:@"parameter type"
                     value2:self.globalParametersType];

    return YES;
}

#pragma mark Internal Methods
- (BOOL)ccTryHandleClientActionWithClientActionIoInjectedData:(nonnull ADJIoData *)clientActionIoInjectedData
                                                 apiTimestamp:(nonnull ADJTimestampMilli *)apiTimestamp
                              clientActionRemoveStorageAction:(nonnull ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction {
    ADJNonEmptyString *_Nullable clientActionType = [clientActionIoInjectedData.metadataMap
                                                     pairValueWithKey:ADJClientActionTypeKey];

    if (clientActionType == nil) {
        [self.logger debugDev:
         @"Cannot handle global parameter client action without clientActionType"
                          key:@"parameter type"
                        value:self.globalParametersType];
        return NO;
    }

    if ([ADJClientAddGlobalParameterDataMetadataTypeValue
         isEqualToString:clientActionType.stringValue])
    {
        ADJClientAddGlobalParameterData *_Nullable clientAddGlobalParameterData =
            [ADJClientAddGlobalParameterData
             instanceFromClientActionInjectedIoDataWithData:clientActionIoInjectedData
             globalParameterType:self.globalParametersType
             logger:self.logger];
        if (clientAddGlobalParameterData == nil) {
            return NO;
        }

        return [self ccAddGlobalParameterWithClientData:clientAddGlobalParameterData
                                           apiTimestamp:apiTimestamp
                    clientActionRemoveStorageActionData:clientActionRemoveStorageAction];
    }

    if ([ADJClientRemoveGlobalParameterDataMetadataTypeValue
         isEqualToString:clientActionType.stringValue])
    {
        ADJClientRemoveGlobalParameterData *_Nullable clientRemoveGlobalParameterData =
            [ADJClientRemoveGlobalParameterData
             instanceFromClientActionInjectedIoDataWithData:clientActionIoInjectedData
             globalParameterType:self.globalParametersType
             logger:self.logger];
        if (clientRemoveGlobalParameterData == nil) {
            return NO;
        }

        return [self ccRemoveGlobalParameterWithClientData:clientRemoveGlobalParameterData
                                              apiTimestamp:apiTimestamp
                       clientActionRemoveStorageActionData:clientActionRemoveStorageAction];
    }

    if ([ADJClientClearGlobalParametersDataMetadataTypeValue
         isEqualToString:clientActionType.stringValue])
    {
        ADJClientClearGlobalParametersData *_Nullable clientClearGlobalParametersData =
            [ADJClientClearGlobalParametersData
             instanceFromClientActionInjectedIoDataWithData:clientActionIoInjectedData
             logger:self.logger];
        if (clientClearGlobalParametersData == nil) {
            return NO;
        }

        return [self ccClearGlobalParameterWithClientData:clientClearGlobalParametersData
                                             apiTimestamp:apiTimestamp
                      clientActionRemoveStorageActionData:clientActionRemoveStorageAction];
    }

    [self.logger debugDev:
     @"Cannot handle global parameter client action with unknown client action type"
                     key1:@"parameter type"
                   value1:self.globalParametersType
                     key2:@"clientActionType"
                   value2:clientActionType.stringValue
                issueType:ADJIssueInvalidInput];

    return NO;
}

@end


