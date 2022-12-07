//
//  ADJAdjustInternal.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADJSdkConfigDataBuilder;
@protocol ADJAdjustInstance;

@interface ADJAdjustInternal : NSObject

+ (nonnull id<ADJAdjustInstance>)sdkInstanceForId:(nullable NSString *)instanceId;

+ (nonnull NSString *)teardownWithSdkConfigDataBuilder:(nullable ADJSdkConfigDataBuilder *)sdkConfigDataBuilder
                                          clearStorage:(BOOL)clearStorage;

+ (nonnull NSString *)sdkVersion;

+ (nonnull NSString *)sdkVersionWithSdkPrefix:(nullable NSString *)sdkPrefix;

@end
