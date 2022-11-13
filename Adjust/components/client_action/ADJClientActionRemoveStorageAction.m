//
//  ADJClientActionRemoveStorageAction.m
//  Adjust
//
//  Created by Aditi Agrawal on 02/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientActionRemoveStorageAction.h"

@interface ADJClientActionRemoveStorageAction ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJClientActionStorage *clientActionStorageWeak;
@property (nonnull, readonly, strong, nonatomic) ADJNonNegativeInt *elementPosition;

@end

@implementation ADJClientActionRemoveStorageAction
#pragma mark Instantiation
- (nonnull instancetype)initWithClientActionStorage:(nonnull ADJClientActionStorage *)clientActionStorage
    elementPosition:(nonnull ADJNonNegativeInt *)elementPosition {
    self = [super initWithDecoratedSQLiteStorageAction:nil];
    _clientActionStorageWeak = clientActionStorage;
    _elementPosition = elementPosition;

    // delete in memory, since it will be deleted in storage later on
    [clientActionStorage removeElementByPositionInMemoryOnly:elementPosition];

    return self;
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSQLiteStorageActionBase
- (BOOL)concretePerformStorageActionInDbTransaction:(nonnull ADJSQLiteDb *)sqliteDb
                                             logger:(nonnull ADJLogger *)logger
{
    ADJClientActionStorage *_Nullable clientActionStorage = self.clientActionStorageWeak;

    if (clientActionStorage == nil) {
        [logger debugDev:@"Cannot perform ClientAction Storage Disposal action"
            " in db transaction without a reference to storage"
               issueType:ADJIssueWeakReference];
        // rollback rest of transaction
        return NO;
    }

    return [clientActionStorage removeElementByPositionInTransaction:self.elementPosition
                                                            sqliteDb:sqliteDb];
}

- (void)concretePerformStorageActionSelfContained {
    ADJClientActionStorage *_Nullable clientActionStorage = self.clientActionStorageWeak;

    if (clientActionStorage == nil) {
        return;
    }

    [clientActionStorage removeElementByPositionInStorageOnly:self.elementPosition];
}

@end
