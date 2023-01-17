//
//  ADJEntryRoot.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJSdkConfigDataBuilder.h"
#import "ADJInstanceRoot.h"

@interface ADJEntryRoot : NSObject
// instantiation
- (nonnull instancetype)initWithInstanceId:(nullable NSString *)instanceId
                          sdkConfigBuilder:(nullable ADJSdkConfigDataBuilder *)sdkConfigBuilder NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;
- (nonnull ADJInstanceRoot *)instanceForId:(nullable NSString *)instanceId;
- (void)finalizeAtTeardownWithCloseStorageBlock:(nullable void (^)(void))closeStorageBlock;

@end

