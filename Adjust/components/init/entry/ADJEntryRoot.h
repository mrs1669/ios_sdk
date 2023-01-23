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
- (nonnull instancetype)initWithClientId:(nullable NSString *)clientId
                        sdkConfigBuilder:(nullable ADJSdkConfigDataBuilder *)sdkConfigBuilder
    NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (nonnull ADJInstanceRoot *)instanceForClientId:(nullable NSString *)clientId;

- (void)finalizeAtTeardownWithCloseStorageBlock:(nullable void (^)(void))closeStorageBlock;

@end

