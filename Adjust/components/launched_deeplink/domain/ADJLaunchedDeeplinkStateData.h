//
//  ADJLaunchedDeeplinkStateData.h
//  Adjust
//
//  Created by Aditi Agrawal on 27/03/23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataSerializable.h"
#import "ADJIoData.h"
#import "ADJNonEmptyString.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJLaunchedDeeplinkStateDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJLaunchedDeeplinkStateData : NSObject<ADJIoDataSerializable>
// instantiation
+ (nonnull ADJResultNN<ADJLaunchedDeeplinkStateData *> *)
    instanceFromIoData:(nonnull ADJIoData *)ioData;

- (nonnull instancetype)initWithInitialState;

- (nonnull instancetype)initWithLaunchedDeeplink:(nullable ADJNonEmptyString *)launchedDeeplink;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *launchedDeeplink;

@end


