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
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData {
    ADJV4ActivityState *_Nullable v4ActivityState = [v4FilesData v4ActivityState];
    if (v4ActivityState == nil) {
        [self.logger debugDev:@"Activity state v4 file not found"];
        return;
    }

    if (v4ActivityState.transactionIds == nil) {
        [self.logger debugDev:@"Cannot find event deduplication list"
         " in v4 activity state file"];
        return;
    }

    for (id _Nonnull transactionIdObject in v4ActivityState.transactionIds) {
        if (! [transactionIdObject isKindOfClass:[NSString class]]) {
            continue;
        }

        NSString *_Nonnull transactionId = (NSString *)transactionIdObject;

        ADJResultNN<ADJNonEmptyString *> *_Nonnull deduplicationIdResult =
            [ADJNonEmptyString instanceFromString:transactionId];
        if (deduplicationIdResult.fail != nil) {
            [self.logger debugDev:@"Invalid transaction id for v4 migration of event deduplication"
                       resultFail:deduplicationIdResult.fail
                        issueType:ADJIssueStorageIo];
            continue;
        }

        [self enqueueElementToLast:
         [[ADJEventDeduplicationData alloc] initWithDeduplicationId:deduplicationIdResult.value]
               sqliteStorageAction:nil];
    }
}

@end
