//
//  ADJLaunchedDeeplinkStateStorage.h
//  Adjust
//
//  Created by Aditi Agrawal on 27/03/23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteStoragePropertiesBase.h"
#import "ADJLaunchedDeeplinkStateData.h"
#import "ADJSQLiteStorage.h"

@interface ADJLaunchedDeeplinkStateStorage : ADJSQLiteStoragePropertiesBase<ADJLaunchedDeeplinkStateData *>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController;

@end

