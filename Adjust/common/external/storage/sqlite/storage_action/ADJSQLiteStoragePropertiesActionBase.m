//
//  ADJSQLiteStoragePropertiesActionBase.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSQLiteStoragePropertiesActionBase.h"

#pragma mark Fields
@interface ADJSQLiteStoragePropertiesActionBase ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJSQLiteStoragePropertiesBase *sqliteStoragePropertiesWeak;
@property (nonnull, readonly, strong, nonatomic) id data;

@end

@implementation ADJSQLiteStoragePropertiesActionBase
#pragma mark Instantiation
- (nonnull instancetype)initWithPropertiesStorage:(nonnull ADJSQLiteStoragePropertiesBase *)sqliteStorageProperties
                                             data:(nonnull id)data
                     decoratedSQLiteStorageAction:(nullable ADJSQLiteStorageActionBase *)decoratedSQLiteStorageAction {
    self = [super initWithDecoratedSQLiteStorageAction:decoratedSQLiteStorageAction];
    _sqliteStoragePropertiesWeak = sqliteStorageProperties;
    _data = data;

    // save it in memory, since it will be saved in memory later on
    [sqliteStorageProperties updateInMemoryOnlyWithNewDataValue:data];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStorageActionBase
- (BOOL)concretePerformStorageActionInDbTransaction:(nonnull ADJSQLiteDb *)sqliteDb
                                             logger:(nonnull ADJLogger *)logger {
    ADJSQLiteStoragePropertiesBase *_Nullable sqliteStorageProperties =
    self.sqliteStoragePropertiesWeak;

    if (sqliteStorageProperties == nil) {
        [logger debugDev:
         @"Cannot perform properties storage action"
         " in db transaction without a reference to storage"
               issueType:ADJIssueWeakReference];
        // rollback rest of transaction
        return NO;
    }

    return [sqliteStorageProperties updateInTransactionWithsSQLiteDb:sqliteDb
                                                        newDataValue:self.data];
}

- (void)concretePerformStorageActionSelfContained {
    ADJSQLiteStoragePropertiesBase *_Nullable sqliteStorageProperties =
    self.sqliteStoragePropertiesWeak;

    if (sqliteStorageProperties == nil) {
        return;
    }

    [sqliteStorageProperties updateInStorageOnlyWithNewDataValue:self.data];
}

@end

