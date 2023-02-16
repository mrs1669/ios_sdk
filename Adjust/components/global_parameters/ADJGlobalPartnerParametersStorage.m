//
//  ADJGlobalPartnerParametersStorage.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGlobalPartnerParametersStorage.h"

#import "ADJStringMapBuilder.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kGlobalPartnerParametersStorageTableName = @"global_partner_parameters";

@implementation ADJGlobalPartnerParametersStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"GlobalPartnerParametersStorage"
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
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    NSDictionary<NSString *, NSString *> *_Nullable v4SessionPartnerParameters = [v4FilesData v4SessionPartnerParameters];
    if (v4SessionPartnerParameters == nil) {
        [self.logger debugDev:@"Session Partner Parameters v4 file not found"];
        return;
    }

    ADJStringMapBuilder *_Nonnull mapBuilder = [[ADJStringMapBuilder alloc] initWithEmptyMap];

    for (NSString *_Nonnull key in v4SessionPartnerParameters) {
        ADJResultNL<ADJNonEmptyString *> *_Nonnull keyResult =
            [ADJNonEmptyString instanceFromOptionalString:key];
        if (keyResult.failMessage != nil) {
            [self.logger debugDev:@"Invalid v4 Session Partner Parameter key"
                      failMessage:keyResult.failMessage
                        issueType:ADJIssueStorageIo];
        }
        if (keyResult.value == nil) {
            continue;
        }

        ADJResultNL<ADJNonEmptyString *> *_Nonnull valueResult =
            [ADJNonEmptyString instanceFromOptionalString:
             [v4SessionPartnerParameters objectForKey:key]];
        if (valueResult.failMessage != nil) {
            [self.logger debugDev:@"Invalid v4 Session Partner Parameter value"
                      failMessage:valueResult.failMessage
                        issueType:ADJIssueStorageIo];
        }
        if (valueResult.value == nil) {
            continue;
        }

        [mapBuilder addPairWithValue:valueResult.value
                                 key:keyResult.value.stringValue];
    }

    [self replaceAllWithStringMap:[[ADJStringMap alloc] initWithStringMapBuilder:mapBuilder]
              sqliteStorageAction:nil];
}

@end

