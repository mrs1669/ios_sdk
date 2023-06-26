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
#import "ADJV4ActivityState.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJEventStateDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJEventStateData : NSObject<ADJIoDataSerializable>
// instantiation
+ (nonnull ADJResult<ADJEventStateData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData;

- (nonnull instancetype)initWithIntialState;

- (nonnull instancetype)initWithEventCount:(nonnull ADJTallyCounter *)eventCount;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (nonnull ADJEventStateData *)generateIncrementedEventCountStateData;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJTallyCounter *eventCount;

@end
