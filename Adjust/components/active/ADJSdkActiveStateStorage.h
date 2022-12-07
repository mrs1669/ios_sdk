//
//  ADJSdkActiveStateStorage.h
//  AdjustV5
//
//  Created by Pedro S. on 21.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteStoragePropertiesBase.h"
#import "ADJSdkActiveStateData.h"
#import "ADJSQLiteStorage.h"

@interface ADJSdkActiveStateStorage : ADJSQLiteStoragePropertiesBase<ADJSdkActiveStateData *>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController;

@end
