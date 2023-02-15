//
//  ADJSessionDeviceIdsController.h
//  Adjust
//
//  Created by Pedro S. on 26.07.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJThreadExecutorFactory.h"
#import "ADJSessionDeviceIdsData.h"
//#import "ADJExternalConfigData.h"
#import "ADJTimeLengthMilli.h"

@interface ADJSessionDeviceIdsController : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                        threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
                            timeoutPerAttempt:(nullable ADJTimeLengthMilli *)timeoutPerAttempt
                                 canCacheData:(BOOL)canCacheData;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (nonnull ADJSessionDeviceIdsData *)getSessionDeviceIdsSync;

- (void)invalidateCache;

@end

