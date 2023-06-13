//
//  ADJAdidStateData.h
//  Adjust
//
//  Created by Pedro Silva on 13.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataSerializable.h"
#import "ADJIoData.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJAdidStateDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJAdidStateData : NSObject<ADJIoDataSerializable>
// public properties
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adid;

// instantiation
+ (nonnull ADJResult<ADJAdidStateData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData;

- (nonnull instancetype)initWithIntialState;

- (nonnull instancetype)initWithAdid:(nullable ADJNonEmptyString *)adid;

- (nullable instancetype)init NS_UNAVAILABLE;

@end
