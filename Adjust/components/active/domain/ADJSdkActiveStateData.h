//
//  ADJSdkActiveStateData.h
//  AdjustV5
//
//  Created by Pedro S. on 21.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataSerializable.h"
#import "ADJIoData.h"
#import "ADJV4ActivityState.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJSdkActiveStateDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJSdkActiveStateData : NSObject<ADJIoDataSerializable>
// instantiation
+ (nonnull ADJResultNN<ADJSdkActiveStateData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData;

- (nonnull instancetype)initWithInitialState;

- (nonnull instancetype)initWithActiveSdk;

- (nonnull instancetype)initWithInactiveSdk;

+ (nullable ADJSdkActiveStateData *)instanceFromV4WithActivityState:
    (nullable ADJV4ActivityState *)v4ActivityState;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonatomic, assign) BOOL isSdkActive;

@end
