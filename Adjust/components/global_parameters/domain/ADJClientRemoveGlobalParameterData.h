//
//  ADJClientRemoveGlobalParameterData.h
//  Adjust
//
//  Created by Aditi Agrawal on 25/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientActionIoDataInjectable.h"
#import "ADJLogger.h"
#import "ADJNonEmptyString.h"
#import "ADJIoData.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJClientRemoveGlobalParameterDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJClientRemoveGlobalParameterData : NSObject<NSCopying,
   ADJClientActionIoDataInjectable
>
// instantiation
+ (nullable instancetype)
    instanceFromClientWithAdjustConfigWithKeyToRemove:(nullable NSString *)keyToRemove
    globalParameterType:(nonnull NSString *)globalParameterType
    logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)
    instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
    globalParameterType:(nonnull NSString *)globalParameterType
    logger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *keyToRemove;

@end
