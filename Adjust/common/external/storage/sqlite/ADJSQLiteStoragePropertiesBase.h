//
//  ADJSQLiteStoragePropertiesBase.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteStorageBase.h"
#import "ADJSQLiteController.h"
#import "ADJSQLiteDb.h"
#import "ADJIoData.h"

@interface ADJSQLiteStoragePropertiesBase<D> : ADJSQLiteStorageBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                       source:(nonnull NSString *)source
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
                                    tableName:(nonnull NSString *)tableName
                            metadataTypeValue:(nonnull NSString *)metadataTypeValue
                      initialDefaultDataValue:(nonnull D)initialDefaultDataValue;

// public api
- (nonnull D)readOnlyStoredDataValue;

- (void)updateWithNewDataValue:(nonnull D)newDataValue;

- (void)updateInMemoryOnlyWithNewDataValue:(nonnull D)newDataValue;
- (void)updateInStorageOnlyWithNewDataValue:(nonnull D)newDataValue;
- (BOOL)updateInTransactionWithsSQLiteDb:(nonnull ADJSQLiteDb *)sqliteDb
                            newDataValue:(nonnull D)newDataValue;

// protected abstract
- (nonnull ADJResultNN<D> *)concreteGenerateValueFromIoData:(nonnull ADJIoData *)ioData;

- (nonnull ADJIoData *)concreteGenerateIoDataFromValue:(nonnull D)dataValue;

@end
