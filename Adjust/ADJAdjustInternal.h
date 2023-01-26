//
//  ADJAdjustInternal.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADJSdkConfigData;
@protocol ADJAdjustInstance;

@interface ADJAdjustInternal : NSObject

+ (nonnull id<ADJAdjustInstance>)sdkInstanceForClientId:(nullable NSString *)clientId;

+ (nonnull NSString *)teardownWithSdkConfigData:(nullable ADJSdkConfigData *)sdkConfigData
                             shouldClearStorage:(BOOL)shouldClearStorage;

+ (nonnull NSString *)sdkVersion;

+ (nonnull NSString *)sdkVersionWithSdkPrefix:(nullable NSString *)sdkPrefix;

@end
