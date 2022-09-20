//
//  ADJMeasurementSessionStateStorageAction.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJMeasurementSessionStateData.h"
#import "ADJSQLiteStoragePropertiesActionBase.h"
#import "ADJMeasurementSessionStateStorage.h"

@interface ADJMeasurementSessionStateStorageAction : ADJSQLiteStoragePropertiesActionBase<ADJMeasurementSessionStateData *>
// instantiation
- (nonnull instancetype)initWithMeasurementSessionStateStorage:(nonnull ADJMeasurementSessionStateStorage *)measurementSessionStateStorage
                                   measurementSessionStateData:(nonnull ADJMeasurementSessionStateData *)measurementSessionStateData;

@end
