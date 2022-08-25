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
- (nullable NSString *)sqlStringForOnUpgrade:(int)oldVersion {
    // nothing to upgrade from (yet)
    return nil;
}

- (void)migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    NSDictionary<NSString *, NSString *> *_Nullable v4SessionPartnerParameters =
    [v4FilesData v4SessionPartnerParameters];
    if (v4SessionPartnerParameters == nil) {
        [self.logger debug:@"Session Partner Parameters v4 file not found"];
        return;
    }

    ADJStringMapBuilder *_Nonnull mapBuilder = [[ADJStringMapBuilder alloc] initWithEmptyMap];

    for (NSString *_Nullable key in v4SessionPartnerParameters) {
        if (key == nil) {
            continue;
        }

        NSString *_Nullable value = [v4SessionPartnerParameters objectForKey:key];
        if (value == nil) {
            continue;
        }

        ADJNonEmptyString *_Nullable verifiedKey =
        [ADJNonEmptyString instanceFromOptionalString:key
                                    sourceDescription:@"v4 Session Partner Parameter key"
                                               logger:self.logger];
        if (verifiedKey == nil) {
            continue;
        }

        ADJNonEmptyString *_Nullable verifiedValue =
        [ADJNonEmptyString instanceFromOptionalString:value
                                    sourceDescription:@"v4 Session Partner Parameter value"
                                               logger:self.logger];
        if (verifiedValue == nil) {
            continue;
        }

        [mapBuilder addPairWithValue:verifiedValue
                                 key:key];
    }

    [self replaceAllWithStringMap:[[ADJStringMap alloc] initWithStringMapBuilder:mapBuilder]
              sqliteStorageAction:nil];
}

@end
