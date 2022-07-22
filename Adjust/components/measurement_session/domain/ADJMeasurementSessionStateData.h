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
#import "ADJLogger.h"
#import "ADJMeasurementSessionData.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJMeasurementSessionStateDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJMeasurementSessionStateData : NSObject<ADJIoDataSerializable>
// instantiation
+ (nullable instancetype)instanceFromIoData:(nonnull ADJIoData *)ioData
                                     logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)
    instanceFromExternalWithMeasurementSessionData:(nullable ADJMeasurementSessionData *)measurementSessionData
    logger:(nonnull ADJLogger *)logger;

- (nonnull instancetype)initWithIntialState;

- (nonnull instancetype)initWithMeasurementSessionData:(nullable ADJMeasurementSessionData *)measurementSessionData
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJMeasurementSessionData *measurementSessionData;

@end
