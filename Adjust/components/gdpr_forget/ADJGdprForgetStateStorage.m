//
//  ADJGdprForgetStateStorage.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGdprForgetStateStorage.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kGdprForgetStateStorageTableName = @"gdpr_forget_state";

@implementation ADJGdprForgetStateStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"GdprForgetStateStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kGdprForgetStateStorageTableName
                      metadataTypeValue:ADJGdprForgetStateDataMetadataTypeValue
                initialDefaultDataValue:
            [[ADJGdprForgetStateData alloc] initWithInitialState]];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStoragePropertiesBase
- (nullable ADJGdprForgetStateData *)concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData {
    return [ADJGdprForgetStateData instanceFromIoData:ioData
                                               logger:self.logger];
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull ADJGdprForgetStateData *)dataValue {
    return [dataValue toIoData];
}

#pragma mark Public API
#pragma mark - ADJSQLiteStorage
- (nullable NSString *)sqlStringForOnUpgrade:(int)oldVersion {
    // nothing to upgrade from (yet)
    return nil;
}

- (void)migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    NSNumber *_Nullable gdprForgetMeNumberBool = v4UserDefaultsData.gdprForgetMeNumberBool;

    if (gdprForgetMeNumberBool != nil && gdprForgetMeNumberBool.boolValue) {
        [self.logger debug:@"GDPR forgotten state found in v4 shared preferences"];
        [self updateWithNewDataValue:[[ADJGdprForgetStateData alloc] initAskedButNotForgotten]];
        return;
    }

    [self.logger debug:@"GDPR forgotten state not found in v4 shared preferences"];

    ADJV4ActivityState *_Nullable v4ActivityState = [v4FilesData v4ActivityState];
    if (v4ActivityState == nil) {
        [self.logger debug:@"Activity state v4 file not found"];
        return;
    }

    if (v4ActivityState.isGdprForgottenNumberBool == nil) {
        [self.logger debug:@"Cannot find is isGdprForgotten v4 activity state file"];
        return;
    }

    if (! v4ActivityState.isGdprForgottenNumberBool.boolValue) {
        [self.logger debug:@"Cannot use false isGdprForgotten in v4 activity state file"];
        return;
    }

    [self.logger debug:@"GDPR forgotten state found in v4 activity state file"];

    [self updateWithNewDataValue:[[ADJGdprForgetStateData alloc] initAskedButNotForgotten]];
}

@end


