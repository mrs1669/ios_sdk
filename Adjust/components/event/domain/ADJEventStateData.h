//
//  ADJEventStateData.h
//  Adjust
//
//  Created by Aditi Agrawal on 03/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataSerializable.h"
#import "ADJIoData.h"
#import "ADJTallyCounter.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJEventStateDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJEventStateData : NSObject<ADJIoDataSerializable>
// instantiation
+ (nullable instancetype)instanceFromIoData:(nonnull ADJIoData *)ioData
                                     logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromExternalWithEventCountNumberInt:(nonnull NSNumber *)eventCountNumberInt
                                                              logger:(nonnull ADJLogger *)logger;

- (nonnull instancetype)initWithIntialState;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (nonnull ADJEventStateData *)generateIncrementedEventCountStateData;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJTallyCounter *eventCount;

@end
