//
//  ADJAsaAttributionStateStorageAction.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAsaAttributionStateStorageAction.h"

@implementation ADJAsaAttributionStateStorageAction
#pragma mark Instantiation
- (nonnull instancetype)initWithAsaAttributionStateStorage:(nonnull ADJAsaAttributionStateStorage *)asaAttributionStateStorage
                                   asaAttributionStateData:(nonnull ADJAsaAttributionStateData *)asaAttributionStateData {
    self = [super initWithPropertiesStorage:asaAttributionStateStorage
                                       data:asaAttributionStateData
               decoratedSQLiteStorageAction:nil];

    return self;
}

@end
