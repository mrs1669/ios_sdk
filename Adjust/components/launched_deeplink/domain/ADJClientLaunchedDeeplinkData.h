//
//  ADJClientLaunchedDeeplinkData.h
//  Adjust
//
//  Created by Aditi Agrawal on 08/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientActionIoDataInjectable.h"
#import "ADJAdjustLaunchedDeeplink.h"
#import "ADJIoData.h"
#import "ADJLogger.h"
#import "ADJNonEmptyString.h"
#import "ADJStringMap.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJClientLaunchedDeeplinkDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJClientLaunchedDeeplinkData : NSObject<ADJClientActionIoDataInjectable>
// instantiation
+ (nullable instancetype)
    instanceFromClientWithAdjustLaunchedDeeplink:
        (nullable ADJAdjustLaunchedDeeplink *)adjustLaunchedDeeplink
    logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)
    instanceFromClientActionInjectedIoDataWithData:
        (nonnull ADJIoData *)clientActionInjectedIoData
    logger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *launchedDeeplink;

@end
