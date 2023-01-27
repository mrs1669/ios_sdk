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

@interface ADJEntryRoot : NSObject
// instantiation
- (nonnull instancetype)initWithClientId:(nullable NSString *)clientId
                           sdkConfigData:(nullable ADJSdkConfigData *)sdkConfigData
    NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) NSString *sdkPrefix;

// public api
- (nonnull ADJInstanceRoot *)instanceForClientId:(nullable NSString *)clientId;

- (void)setSdkPrefix:(nullable NSString *)sdkPrefix;

- (void)finalizeAtTeardownWithCloseStorageBlock:(nullable void (^)(void))closeStorageBlock;

@end

