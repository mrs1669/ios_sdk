//
//  ADJGlobalCallbackParametersStorage.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGlobalCallbackParametersStorage.h"

#import "ADJStringMapBuilder.h"

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
- (nullable NSString *)sqlStringForOnUpgrade:(int)oldVersion {
    // nothing to upgrade from (yet)
    return nil;
}

- (void)migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    NSDictionary<NSString *, NSString *> *_Nullable v4SessionCallbackParameters =
        [v4FilesData v4SessionCallbackParameters];
    if (v4SessionCallbackParameters == nil) {
        [self.logger debugDev:@"Session Callback Parameters v4 file not found"];
        return;
    }

    ADJStringMapBuilder *_Nonnull mapBuilder = [[ADJStringMapBuilder alloc] initWithEmptyMap];

    for (NSString *_Nullable key in v4SessionCallbackParameters) {
        if (key == nil) {
            continue;
        }

        NSString *_Nullable value = [v4SessionCallbackParameters objectForKey:key];
        if (value == nil) {
            continue;
        }

        ADJNonEmptyString *_Nullable verifiedKey =
            [ADJNonEmptyString instanceFromOptionalString:key
                                        sourceDescription:@"v4 Session Callback Parameter key"
                                                   logger:self.logger];
        if (verifiedKey == nil) {
            continue;
        }

        ADJNonEmptyString *_Nullable verifiedValue =
            [ADJNonEmptyString instanceFromOptionalString:value
                                        sourceDescription:@"v4 Session Callback Parameter value"
                                                   logger:self.logger];
        if (verifiedValue == nil) {
            continue;
        }

        [mapBuilder addPairWithValue:verifiedValue key:key];
    }

    [self replaceAllWithStringMap:[[ADJStringMap alloc] initWithStringMapBuilder:mapBuilder]
              sqliteStorageAction:nil];
}

@end

