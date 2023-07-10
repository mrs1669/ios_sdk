//
//  ADJAdidStateStorage.h
//  Adjust
//
//  Created by Pedro Silva on 13.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteStoragePropertiesBase.h"
#import "ADJAdidStateData.h"
#import "ADJSQLiteStorage.h"

@interface ADJAdidStateStorage : ADJSQLiteStoragePropertiesBase<ADJAdidStateData *>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController;

@end
