//
//  ADJSQLiteStorageQueueMetadataAction.h
//  Adjust
//
//  Created by Pedro Silva on 30.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteStorageActionBase.h"
#import "ADJSQLiteStorageQueueBase.h"
#import "ADJStringMap.h"

@interface ADJSQLiteStorageQueueMetadataAction : ADJSQLiteStorageActionBase
// instantiation
- (nonnull instancetype)
    initWithQueueStorage:(nonnull ADJSQLiteStorageQueueBase *)sqliteStorageQueue
    metadataMap:(nonnull ADJStringMap *)metadataMap
    decoratedSQLiteStorageAction:
        (nullable ADJSQLiteStorageActionBase *)decoratedSQLiteStorageAction;

@end
