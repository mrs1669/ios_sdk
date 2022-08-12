//
//  ADJAdjustInternal.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADJEntryRoot;
#import "ADJSdkConfigDataBuilder.h"

@interface ADJAdjustInternal : NSObject

+ (nonnull ADJEntryRoot *)rootInstance;

+ (nonnull NSString *)teardownWithShouldClearStorage:(BOOL)shouldClearStorage
                                sdkConfigDataBuilder:(nullable ADJSdkConfigDataBuilder *)sdkConfigDataBuilder;

+ (nonnull NSString *)sdkVersion;

+ (nonnull NSString *)sdkVersionWithSdkPrefix:(nullable NSString *)sdkPrefix;

@end
