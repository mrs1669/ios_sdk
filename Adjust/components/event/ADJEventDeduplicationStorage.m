//
//  ADJEventDeduplicationStorage.m
//  Adjust
//
//  Created by Pedro S. on 17.03.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJEventDeduplicationStorage.h"

#import "ADJUtilF.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kEventDeduplicationStorageTableName = @"event_deduplication";

@implementation ADJEventDeduplicationStorage
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
{
    self = [super initWithLoggerFactory:loggerFactory
                             loggerName:@"EventDeduplicationStorage"
                        storageExecutor:storageExecutor
                       sqliteController:sqliteController
                              tableName:kEventDeduplicationStorageTableName
                      metadataTypeValue:ADJEventDeduplicationDataMetadataTypeValue];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStorageQueueBase
- (nonnull ADJResult<ADJEventDeduplicationData *> *)concreteGenerateElementFromIoData:(nonnull ADJIoData *)ioData {
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
    NSArray<ADJEventDeduplicationData *> *_Nullable eventDeduplicationArray =
        [self eventDeduplicationArrayFromV4:[v4FilesData v4ActivityState]];

    if (eventDeduplicationArray == nil) {
        return;
    }

    for (ADJEventDeduplicationData *_Nonnull eventDedup in eventDeduplicationArray) {
        [self enqueueElementToLast:eventDedup sqliteStorageAction:nil];
    }
}

- (nullable NSArray<ADJEventDeduplicationData *> *)
    eventDeduplicationArrayFromV4:(nullable ADJV4ActivityState *)v4ActivityState
{
    if (v4ActivityState == nil || v4ActivityState.transactionIds == nil) {
        return nil;
    }

    NSMutableArray<ADJEventDeduplicationData *> *_Nonnull dedupsArrayMut =
        [[NSMutableArray alloc] init];

    for (NSUInteger i = 0; i < v4ActivityState.transactionIds.count; i = i + 1) {
        ADJResult<ADJNonEmptyString *> *_Nonnull transactionIdResult =
            [ADJNonEmptyString instanceFromObject:[v4ActivityState.transactionIds objectAtIndex:i]];

        if (transactionIdResult.fail != nil) {
            [self.logger debugDev:@"Invalid value from v4 activity state transactionIds"
                              key:@"transactionIds index"
                      stringValue:[ADJUtilF uIntegerFormat:i]
                       resultFail:transactionIdResult.fail
                        issueType:ADJIssueStorageIo];
        } else {
            [dedupsArrayMut addObject:[[ADJEventDeduplicationData alloc]
                                       initWithDeduplicationId:transactionIdResult.value]];
        }
    }


    if ([dedupsArrayMut count] == 0) {
        return nil;
    }

    return dedupsArrayMut;
}

@end
