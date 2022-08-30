//
//  ADJClientAddGlobalParameterData.h
//  Adjust
//
//  Created by Aditi Agrawal on 03/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientActionIoDataInjectable.h"
#import "ADJLogger.h"
#import "ADJNonEmptyString.h"
#import "ADJIoData.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJClientAddGlobalParameterDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJClientAddGlobalParameterData : NSObject<NSCopying,
ADJClientActionIoDataInjectable
>
// instantiation
+ (nullable instancetype)instanceFromClientWithAdjustConfigWithKeyToAdd:(nullable NSString *)keyToAdd
                                                             valueToAdd:(nullable NSString *)valueToAdd
                                                                 logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *keyToAdd;
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *valueToAdd;

@end
