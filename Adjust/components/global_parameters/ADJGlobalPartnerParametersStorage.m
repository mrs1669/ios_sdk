//
//  ADJGlobalPartnerParametersStorage.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGlobalPartnerParametersStorage.h"

#import "ADJStringMapBuilder.h"
#import "ADJGlobalParametersControllerBase.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kGlobalPartnerParametersStorageTableName = @"global_partner_parameters";

@implementation ADJGlobalPartnerParametersStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:@"GlobalPartnerParametersStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kGlobalPartnerParametersStorageTableName];

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
    ADJOptionalFailsNL<ADJStringMap *> *_Nonnull partnerParamsOptFails =
        [ADJGlobalParametersControllerBase paramsInstanceFromV4WithSessionParameters:
         [v4FilesData v4SessionPartnerParameters]];
    for (ADJResultFail *_Nonnull optionalFail in partnerParamsOptFails.optionalFails) {
        [self.logger debugDev:@"Could not parse value for v4 session partner parameters migration"
                   resultFail:optionalFail
                    issueType:ADJIssueStorageIo];
    }

    if (partnerParamsOptFails.value == nil) {
        return;
    }

    [self replaceAllWithStringMap:partnerParamsOptFails.value
              sqliteStorageAction:nil];
}

@end
