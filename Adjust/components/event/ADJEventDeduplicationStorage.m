//
//  ADJEventDeduplicationStorage.m
//  Adjust
//
//  Created by Pedro S. on 17.03.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJEventDeduplicationStorage.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kEventDeduplicationStorageTableName = @"event_deduplication";

@implementation ADJEventDeduplicationStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"EventDeduplicationStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kEventDeduplicationStorageTableName
                      metadataTypeValue:ADJEventDeduplicationDataMetadataTypeValue];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStorageQueueBase
- (nonnull ADJResultNN<ADJEventDeduplicationData *> *)concreteGenerateElementFromIoData:(nonnull ADJIoData *)ioData {
    return [ADJEventDeduplicationData instanceFromIoData:ioData];
}

- (nonnull ADJIoData *)concreteGenerateIoDataFromElement:(nonnull ADJEventDeduplicationData *)element {
    return [element toIoData];
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
    ADJOptionalFailsNL<NSArray<ADJEventDeduplicationData *> *> *_Nonnull
    eventDeduplicationArrayOptFails =
        [ADJEventDeduplicationData instanceArrayFromV4WithActivityState:
         [v4FilesData v4ActivityState]];
    for (ADJResultFail *_Nonnull optionalFails in eventDeduplicationArrayOptFails.optionalFails) {
        [self.logger debugDev:@"Could not parse value for v4 event deduplication migration"
                   resultFail:optionalFails
                    issueType:ADJIssueStorageIo];
    }

    if (eventDeduplicationArrayOptFails.value == nil) {
        return;
    }

    for (ADJEventDeduplicationData *_Nonnull eventDedup in eventDeduplicationArrayOptFails.value) {
        [self enqueueElementToLast:eventDedup sqliteStorageAction:nil];
    }
}

@end
