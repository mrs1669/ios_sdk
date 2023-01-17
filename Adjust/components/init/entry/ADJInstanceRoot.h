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

@interface ADJInstanceRoot : NSObject <ADJAdjustInstance>

- (nonnull instancetype)initWithConfigData:(nonnull ADJSdkConfigData *)configData
                                instanceId:(nonnull NSString *)instanceId;
- (nullable instancetype)init NS_UNAVAILABLE;
- (void)finalizeAtTeardownWithBlock:(nullable void (^)(void))closeStorageBlock;

@end

