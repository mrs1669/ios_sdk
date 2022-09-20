//
//  ADJAsaAttributionStateStorageAction.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJAsaAttributionStateData.h"
#import "ADJSQLiteStoragePropertiesActionBase.h"
#import "ADJAsaAttributionStateStorage.h"

@interface ADJAsaAttributionStateStorageAction : ADJSQLiteStoragePropertiesActionBase<ADJAsaAttributionStateData *>
// instantiation
- (nonnull instancetype)initWithAsaAttributionStateStorage:(nonnull ADJAsaAttributionStateStorage *)asaAttributionStateStorage
                                   asaAttributionStateData:(nonnull ADJAsaAttributionStateData *)asaAttributionStateData;

@end
