//
//  ADJMeasurementSessionStateStorage.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteStoragePropertiesBase.h"
#import "ADJMeasurementSessionStateData.h"
#import "ADJSQLiteStorage.h"

@interface ADJMeasurementSessionStateStorage :
    ADJSQLiteStoragePropertiesBase<ADJMeasurementSessionStateData *>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              storageExecutor:(nonnull ADJSingleThreadExecutor *)storageExecutor
                             sqliteController:(nonnull ADJSQLiteController *)sqliteController;

@end
