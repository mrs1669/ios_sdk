//
//  ADJEventStateStorage.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteStoragePropertiesBase.h"
#import "ADJEventStateData.h"
#import "ADJSQLiteStorage.h"

@interface ADJEventStateStorage : ADJSQLiteStoragePropertiesBase<ADJEventStateData *>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController;

@end
