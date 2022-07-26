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

@interface ADJSQLiteStorageQueueBase<E> : ADJSQLiteStorageBase
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    source:(nonnull NSString *)source
    storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
    sqliteController:(nonnull ADJSQLiteController *)sqliteController
    tableName:(nonnull NSString *)tableName
    metadataTypeValue:(nonnull NSString *)metadataTypeValue;

// protected abstract
- (nullable E)concreteGenerateElementFromIoData:(nonnull ADJIoData *)ioData;

- (nonnull ADJIoData *)concreteGenerateIoDataFromElement:(nonnull E)element;

// public api
- (nonnull ADJNonNegativeInt *)count;
- (BOOL)isEmpty;
- (nullable E)elementAtFront;
- (nullable E)elementByPosition:(nonnull ADJNonNegativeInt *)elementPosition;

- (nonnull NSArray<E> *) copyElementList;
- (nonnull NSArray<ADJNonNegativeInt *> *)copySortedElementPositionList;
- (nonnull NSDictionary<ADJNonNegativeInt *, E> *)copyElementWithPositionList;

- (nonnull ADJNonNegativeInt *)
    enqueueElementToLast:(nonnull E)newElement
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;
- (nullable E)removeElementAtFront;
- (nullable E)removeElementByPosition:(nonnull ADJNonNegativeInt *)elementPositionToRemove;
- (BOOL)removeElementByPositionInTransaction:(nonnull ADJNonNegativeInt *)elementPositionToRemove
                                    sqliteDb:(nonnull ADJSQLiteDb *)sqliteDb;
- (nullable E)removeElementByPositionInMemoryOnly:
    (nonnull ADJNonNegativeInt *)elementPositionToRemove;
- (void)removeElementByPositionInStorageOnly:(nonnull ADJNonNegativeInt *)elementPositionToRemove;
- (void)removeAllElements;

@end
