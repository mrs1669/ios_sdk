//
//  ADJGlobalCallbackParametersStorage.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGlobalCallbackParametersStorage.h"

#import "ADJStringMapBuilder.h"
#import "ADJGlobalParametersControllerBase.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kGlobalCallbackParametersStorageTableName = @"global_callback_parameters";

@implementation ADJGlobalCallbackParametersStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"GlobalCallbackParametersStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kGlobalCallbackParametersStorageTableName];

    return self;
}

#pragma mark Public API
#pragma mark - ADJSQLiteStorage
- (nullable NSString *)sqlStringForOnUpgrade:(nonnull ADJNonNegativeInt *)oldVersion {
    // nothing to upgrade from (yet)
    return nil;
}

- (void)migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData
{
    ADJOptionalFailsNL<ADJStringMap *> *_Nonnull callbackParamsOptFails =
        [ADJGlobalParametersControllerBase paramsInstanceFromV4WithSessionParameters:
         [v4FilesData v4SessionCallbackParameters]];
    for (ADJResultFail *_Nonnull optionalFail in callbackParamsOptFails.optionalFails) {
        [self.logger debugDev:@"Could not parse value for v4 session callback parameters migration"
                   resultFail:optionalFail
                    issueType:ADJIssueStorageIo];
    }

    if (callbackParamsOptFails.value == nil) {
        return;
    }

    [self replaceAllWithStringMap:callbackParamsOptFails.value
              sqliteStorageAction:nil];
}

@end
