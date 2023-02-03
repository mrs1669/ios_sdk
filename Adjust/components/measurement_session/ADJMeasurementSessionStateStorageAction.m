//
//  ADJMeasurementSessionStateStorageAction.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMeasurementSessionStateStorageAction.h"

@implementation ADJMeasurementSessionStateStorageAction
#pragma mark Instantiation
- (nonnull instancetype)
    initWithMeasurementSessionStateStorage:
        (nonnull ADJMeasurementSessionStateStorage *)measurementSessionStateStorage
    measurementSessionStateData:
        (nonnull ADJMeasurementSessionStateData *)measurementSessionStateData
{
    self = [super initWithPropertiesStorage:measurementSessionStateStorage
                                       data:measurementSessionStateData
               decoratedSQLiteStorageAction:nil];

    return self;
}

@end
