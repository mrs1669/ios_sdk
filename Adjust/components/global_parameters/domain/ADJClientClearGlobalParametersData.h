//
//  ADJClientClearGlobalParametersData.h
//  Adjust
//
//  Created by Aditi Agrawal on 25/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientActionIoDataInjectable.h"
#import "ADJLogger.h"
#import "ADJIoData.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJClientClearGlobalParametersDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJClientClearGlobalParametersData : NSObject<NSCopying,
ADJClientActionIoDataInjectable
>

// instantiation
+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_DESIGNATED_INITIALIZER;

@end
