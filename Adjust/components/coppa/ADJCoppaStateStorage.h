//
//  ADJCoppaStateStorage.h
//  Adjust
//
//  Created by Pedro Silva on 28.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteStoragePropertiesBase.h"
#import "ADJSQLiteStoragePropertiesActionBase.h"
#import "ADJCoppaStateData.h"
#import "ADJSQLiteStorage.h"

@interface ADJCoppaStateStorage : ADJSQLiteStoragePropertiesBase<ADJCoppaStateData *>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController;

@end

@interface ADJCoppaStateStorageAction :
    ADJSQLiteStoragePropertiesActionBase<ADJCoppaStateData *>
// instantiation
- (nonnull instancetype)initWithCoppaStateStorage:(nonnull ADJCoppaStateStorage *)coppaStateStorage
                                   coppaStateData:(nonnull ADJCoppaStateData *)coppaStateData;

@end
