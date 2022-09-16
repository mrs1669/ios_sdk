//
//  ADJAttributionStateStorage.h
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "ADJSQLiteStoragePropertiesBase.h"
#import "ADJAttributionStateData.h"
#import "ADJSQLiteStorage.h"

@interface ADJAttributionStateStorage : ADJSQLiteStoragePropertiesBase<ADJAttributionStateData *>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController;

@end
