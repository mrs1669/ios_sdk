//
//  ADJSQLiteStorageActionBase.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSQLiteStorageActionBase.h"

#import "ADJAtomicBoolean.h"

@interface ADJSQLiteStorageActionBase ()
#pragma mark - Injected dependencies
@property (nullable, readonly, strong, nonatomic)
    ADJSQLiteStorageActionBase *decoratedSQLiteStorageAction;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJAtomicBoolean *actionCalled;

@end

@implementation ADJSQLiteStorageActionBase
- (nonnull instancetype)initWithDecoratedSQLiteStorageAction:
    (nullable ADJSQLiteStorageActionBase *)decoratedSQLiteStorageAction {
    // prevents direct creation of instance, needs to be invoked by subclass
    if ([self isMemberOfClass:[ADJSQLiteStorageActionBase class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }

    self = [super init];

    _decoratedSQLiteStorageAction = decoratedSQLiteStorageAction;

    //_actionCalled = [[ADJAtomicBoolean alloc] initWithSeqCstValue:NO];
    _actionCalled = [[ADJAtomicBoolean alloc] initSeqCstMemoryOrderWithInitialBoolValue:NO];

    return self;
}

#pragma mark Public API
- (BOOL)performStorageActionInDbTransaction:(nonnull ADJSQLiteDb *)sqliteDb
                                     logger:(nonnull ADJLogger *)logger {
    if ([self.actionCalled testAndSetTrue]) {
        // allow the rest of the transaction to be performed
        return YES;
    }

    if (self.decoratedSQLiteStorageAction != nil) {
        BOOL decoratedInTransactionResult =
        [self.decoratedSQLiteStorageAction performStorageActionInDbTransaction:sqliteDb
                                                                        logger:logger];

        if (! decoratedInTransactionResult) {
            return NO;
        }
    }

    return [self concretePerformStorageActionInDbTransaction:sqliteDb
                                                      logger:logger];
}

#pragma mark - ADJRuntimeFinalizer
- (void)finalizeAtRuntime {
    [self performStorageActionSelfContained];
}

#pragma mark Protected Methods
#pragma mark - Abstract
- (BOOL)concretePerformStorageActionInDbTransaction:(nonnull ADJSQLiteDb *)sqliteDb
                                             logger:(nonnull ADJLogger *)logger {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void)concretePerformStorageActionSelfContained {
    [self doesNotRecognizeSelector:_cmd];
    return;
}

#pragma mark Internal Methods
- (void)performStorageActionSelfContained {
    if ([self.actionCalled testAndSetTrue]) {
        return;
    }

    if (self.decoratedSQLiteStorageAction != nil) {
        [self.decoratedSQLiteStorageAction performStorageActionSelfContained];
    }

    [self concretePerformStorageActionSelfContained];
}

@end
