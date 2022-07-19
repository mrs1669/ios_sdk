//
//  ADJClientAPI.h
//  Adjust
//
//  Created by Pedro S. on 29.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientConfigData.h"
#import "ADJAdjustAttributionCallback.h"
#import "ADJAdjustDeviceIdsCallback.h"
#import "ADJClientActionsAPI.h"

@protocol ADJClientAPI <NSObject>

- (void)ccSdkInitWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData;

- (void)ccInactivateSdk;
- (void)ccReactivateSdk;

- (void)ccGdprForgetDevice;

- (void)ccPutSdkOffline;
- (void)ccPutSdkOnline;

- (void)ccForeground;
- (void)ccBackground;

- (void)ccAttributionWithCallback:
    (nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback;
- (void)ccDeviceIdsWithCallback:
    (nonnull id<ADJAdjustDeviceIdsCallback>)adjustDeviceIdsCallback;

- (nullable id<ADJClientActionsAPI>)ccClientActionsWithSource:(nonnull NSString *)source;


@end
