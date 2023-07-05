//
//  ADJMeasurementSessionStateData.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataSerializable.h"
#import "ADJIoData.h"
#import "ADJOptionalFails.h"
#import "ADJMeasurementSessionData.h"
#import "ADJV4ActivityState.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJMeasurementSessionStateDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJMeasurementSessionStateData : NSObject<ADJIoDataSerializable>
// instantiation
+ (nonnull ADJOptionalFails<ADJResult<ADJMeasurementSessionStateData *> *> *)
    instanceFromIoData:(nonnull ADJIoData *)ioData;

+ (nonnull ADJResult<ADJMeasurementSessionStateData *> *)
    instanceFromV4WithActivityState:(nullable ADJV4ActivityState *)v4ActivityState;

- (nonnull instancetype)initWithInitialState;

- (nonnull instancetype)
    initWithMeasurementSessionData:(nullable ADJMeasurementSessionData *)measurementSessionData
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJMeasurementSessionData *measurementSessionData;

@end
