//
//  ADJInstanceRoot.h
//  Adjust
//
//  Created by Genady Buchatsky on 04.11.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJAdjustInstance.h"
#import "ADJSdkConfigData.h"
#import "ADJInstanceIdData.h"
#import "ADJInstanceRootBag.h"

@interface ADJInstanceRoot : NSObject <
    ADJAdjustInstance,
    ADJInstanceRootBag
>
// instantiation
+ (nonnull instancetype)instanceWithConfigData:(nonnull ADJSdkConfigData *)configData
                                    instanceId:(nonnull ADJInstanceIdData *)instanceId
                                     sdkPrefix:(nullable NSString*)sdkPrefix;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)finalizeAtTeardownWithBlock:(nullable void (^)(void))closeStorageBlock;

@end

