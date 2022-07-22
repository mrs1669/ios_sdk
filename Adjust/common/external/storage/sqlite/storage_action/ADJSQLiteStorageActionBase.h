//
//  ADJSQLiteStorageActionBase.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJRuntimeFinalizer.h"
#import "ADJSQLiteDb.h"
#import "ADJLogger.h"

@interface ADJSQLiteStorageActionBase : NSObject<ADJRuntimeFinalizer>
// instantiation
- (nonnull instancetype)initWithDecoratedSQLiteStorageAction:
    (nullable ADJSQLiteStorageActionBase *)decoratedSQLiteStorageAction;

// public api
- (BOOL)performStorageActionInDbTransaction:(nonnull ADJSQLiteDb *)sqliteDb
                                     logger:(nonnull ADJLogger *)logger;

// protected abstract
- (BOOL)concretePerformStorageActionInDbTransaction:(nonnull ADJSQLiteDb *)sqliteDb
                                             logger:(nonnull ADJLogger *)logger;

- (void)concretePerformStorageActionSelfContained;

@end
