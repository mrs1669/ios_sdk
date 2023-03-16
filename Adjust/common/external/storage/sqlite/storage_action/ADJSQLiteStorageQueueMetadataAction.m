//
//  ADJSQLiteStorageQueueMetadataAction.m
//  Adjust
//
//  Created by Pedro Silva on 30.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJSQLiteStorageQueueMetadataAction.h"

#pragma mark Fields
@interface ADJSQLiteStorageQueueMetadataAction ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic)
    ADJSQLiteStorageQueueBase *sqliteStorageQueueWeak;
@property (nonnull, readonly, strong, nonatomic) ADJStringMap *metadataMap;

@end

@implementation ADJSQLiteStorageQueueMetadataAction
#pragma mark Instantiation
- (nonnull instancetype)
    initWithQueueStorage:(nonnull ADJSQLiteStorageQueueBase *)sqliteStorageQueue
    metadataMap:(nonnull ADJStringMap *)metadataMap
    decoratedSQLiteStorageAction:
        (nullable ADJSQLiteStorageActionBase *)decoratedSQLiteStorageAction
{
    self = [super initWithDecoratedSQLiteStorageAction:decoratedSQLiteStorageAction];
    _sqliteStorageQueueWeak = sqliteStorageQueue;
    _metadataMap = metadataMap;

    // save it in memory, since it will be saved in memory later on
    [sqliteStorageQueue updateMetadataInMemoryOnlyWithMap:metadataMap];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStorageActionBase
- (BOOL)concretePerformStorageActionInDbTransaction:(nonnull ADJSQLiteDb *)sqliteDb
                                             logger:(nonnull ADJLogger *)logger
{
    ADJSQLiteStorageQueueBase *_Nullable sqliteStorageQueue = self.sqliteStorageQueueWeak;
    if (sqliteStorageQueue == nil) {
        [logger debugDev:
         @"Cannot perform update queue metadata storage action"
         " in db transaction without a reference to storage"
               issueType:ADJIssueWeakReference];
        // rollback rest of transaction
        return NO;
    }

    return [sqliteStorageQueue updateMetadataInTransactionWithMap:self.metadataMap
                                                         sqliteDb:sqliteDb];
}

- (void)concretePerformStorageActionSelfContained {
    ADJSQLiteStorageQueueBase *_Nullable sqliteStorageQueue = self.sqliteStorageQueueWeak;
    if (sqliteStorageQueue == nil) {
        return;
    }

    [sqliteStorageQueue updateMetadataInStorageOnlyWitMap:self.metadataMap];
}

@end
