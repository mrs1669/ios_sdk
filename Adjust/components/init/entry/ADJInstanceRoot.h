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
#import "ADJEntryRootBag.h"
#import "ADJAdjustInternal.h"

@interface ADJInstanceRoot : NSObject <
    ADJAdjustInstance,
    ADJInstanceRootBag
>
// instantiation
+ (nonnull instancetype)instanceWithConfigData:(nonnull ADJSdkConfigData *)configData
                                    instanceId:(nonnull ADJInstanceIdData *)instanceId
                                  entryRootBag:(nonnull id<ADJEntryRootBag>)entryRootBag;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)
    initSdkWithConfig:(nonnull ADJAdjustConfig *)adjustConfig
    internalConfigSubscriptions:
        (nullable NSDictionary<NSString *, id<ADJInternalCallback>> *)internalConfigSubscriptions;

- (void)adjustAttributionWithInternalCallback:(nonnull id<ADJInternalCallback>)internalCallback;
- (void)adjustDeviceIdsWithInternalCallback:(nonnull id<ADJInternalCallback>)internalCallback;

- (void)finalizeAtTeardownWithBlock:(nullable void (^)(void))closeStorageBlock;

@end
