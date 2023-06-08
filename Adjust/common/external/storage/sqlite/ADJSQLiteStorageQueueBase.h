//
//  ADJSQLiteStorageQueueBase.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteStorageBase.h"
#import "ADJLoggerFactory.h"
#import "ADJSQLiteController.h"
#import "ADJIoData.h"
#import "ADJNonNegativeInt.h"
#import "ADJSQLiteStorageActionBase.h"
#import "ADJSQLiteDb.h"
#import "ADJStringMap.h"

@interface ADJSQLiteStorageQueueBase<E> : ADJSQLiteStorageBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                       source:(nonnull NSString *)source
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController
                                    tableName:(nonnull NSString *)tableName
                            metadataTypeValue:(nonnull NSString *)metadataTypeValue;

// protected abstract
- (nonnull ADJResult<E> *)concreteGenerateElementFromIoData:(nonnull ADJIoData *)ioData;

- (nonnull ADJIoData *)concreteGenerateIoDataFromElement:(nonnull E)element;

// public api
- (nonnull ADJNonNegativeInt *)count;
- (BOOL)isEmpty;
- (nullable ADJNonNegativeInt *)positionAtFront;
- (nullable E)elementAtFront;
- (nullable E)elementByPosition:(nullable ADJNonNegativeInt *)elementPosition;

- (nonnull NSArray<E> *) copyElementList;
- (nonnull NSArray<ADJNonNegativeInt *> *)copySortedElementPositionList;
- (nonnull NSDictionary<ADJNonNegativeInt *, E> *)copyElementWithPositionList;

- (nonnull ADJNonNegativeInt *)
    enqueueElementToLast:(nonnull E)newElement
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;

- (nullable E)removeElementAtFront;

- (nullable E)removeElementByPosition:(nonnull ADJNonNegativeInt *)elementPositionToRemove
                  sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;
- (BOOL)removeElementByPositionInTransaction:(nonnull ADJNonNegativeInt *)elementPositionToRemove
                                    sqliteDb:(nonnull ADJSQLiteDb *)sqliteDb;
- (nullable E)removeElementByPositionInMemoryOnly:
    (nonnull ADJNonNegativeInt *)elementPositionToRemove;
- (void)removeElementByPositionInStorageOnly:(nonnull ADJNonNegativeInt *)elementPositionToRemove;

- (void)removeAllElements;

- (nonnull ADJStringMap *)metadataMap;
- (void)updateMetadataWithMap:(nonnull ADJStringMap *)newMetadataMap;
- (void)updateMetadataInMemoryOnlyWithMap:(nonnull ADJStringMap *)newMetadataMap;
- (BOOL)updateMetadataInTransactionWithMap:(nonnull ADJStringMap *)newMetadataMap
                                  sqliteDb:(nonnull ADJSQLiteDb *)sqliteDb;
- (void)updateMetadataInStorageOnlyWitMap:(nonnull ADJStringMap *)newMetadataMap;

@end
