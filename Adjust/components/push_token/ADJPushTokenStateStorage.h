//
//  ADJPushTokenStateStorage.h
//  Adjust
//
//  Created by Aditi Agrawal on 13/02/23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteStoragePropertiesBase.h"
#import "ADJPushTokenStateData.h"
#import "ADJSQLiteStorage.h"

@interface ADJPushTokenStateStorage : ADJSQLiteStoragePropertiesBase<ADJPushTokenStateData *>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController;

@end
