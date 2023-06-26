//
//  ADJDeviceIdsData.h
//  Adjust
//
//  Created by Pedro S. on 23.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataSerializable.h"
#import "ADJIoData.h"
#import "ADJNonEmptyString.h"
#import "ADJV4ActivityState.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJDeviceIdsDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJDeviceIdsData : NSObject<ADJIoDataSerializable>
// instantiation
+ (nonnull ADJResult<ADJDeviceIdsData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData;

+ (nonnull ADJResult<ADJDeviceIdsData *> *)
    instanceFromV4WithActivityState:(nullable ADJV4ActivityState *)v4ActivityState;

- (nonnull instancetype)initWithInitialState;

- (nonnull instancetype)initWithUuid:(nullable ADJNonEmptyString *)uuid;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *uuid;

@end

