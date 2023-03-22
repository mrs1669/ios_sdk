//
//  ADJClientPushTokenData.h
//  Adjust
//
//  Created by Aditi Agrawal on 30/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientActionIoDataInjectable.h"
#import "ADJAdjustPushToken.h"
#import "ADJLogger.h"
#import "ADJIoData.h"
#import "ADJNonEmptyString.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJClientPushTokenDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJClientPushTokenData : NSObject<ADJClientActionIoDataInjectable>

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *pushTokenString;

// instantiation
+ (nullable instancetype)instanceFromClientWithAdjustPushToken:(nullable ADJAdjustPushToken *)adjustPushToken
                                                        logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_UNAVAILABLE;

@end

