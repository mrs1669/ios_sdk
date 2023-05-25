//
//  ADJEntryRoot.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJSdkConfigData.h"
#import "ADJInstanceRoot.h"
#import "ADJEntryRootBag.h"

@interface ADJEntryRoot : NSObject <ADJEntryRootBag>
// instantiation
+ (nonnull ADJEntryRoot *)instanceWithClientId:(nullable NSString *)clientId
                                 sdkConfigData:(nullable ADJSdkConfigData *)sdkConfigData;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (nonnull ADJInstanceRoot *)instanceForClientId:(nullable NSString *)clientId;

- (void)finalizeAtTeardownWithCloseStorageBlock:(nullable void (^)(void))closeStorageBlock;

+ (void)setSdkPrefix:(nullable NSString *)sdkPrefix;
+ (nullable NSString *)sdkPrefix;

@end

