//
//  ADJSQLiteStoragePropertiesActionBase.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteStorageActionBase.h"
#import "ADJSQLiteStoragePropertiesBase.h"

@interface ADJSQLiteStoragePropertiesActionBase<D> : ADJSQLiteStorageActionBase
// instantiation
- (nonnull instancetype)
    initWithPropertiesStorage:(nonnull ADJSQLiteStoragePropertiesBase *)sqliteStorageProperties
    data:(nonnull D)data
    decoratedSQLiteStorageAction:
        (nullable ADJSQLiteStorageActionBase *)decoratedSQLiteStorageAction;

@end
