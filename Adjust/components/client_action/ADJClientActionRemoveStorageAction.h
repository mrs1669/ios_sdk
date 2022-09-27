//
//  ADJClientActionRemoveStorageAction.h
//  Adjust
//
//  Created by Aditi Agrawal on 02/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteStorageActionBase.h"
#import "ADJClientActionStorage.h"
#import "ADJNonNegativeInt.h"

@interface ADJClientActionRemoveStorageAction : ADJSQLiteStorageActionBase
// instantiation
- (nonnull instancetype)initWithClientActionStorage:(nonnull ADJClientActionStorage *)clientActionStorage
                                    elementPosition:(nonnull ADJNonNegativeInt *)elementPosition;

@end
