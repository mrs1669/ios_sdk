//
//  ADJUtilSys.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJNonEmptyString.h"
#import "ADJRuntimeFinalizer.h"

@interface ADJUtilSys : NSObject

+ (nonnull ADJNonEmptyString *)generateUuid;

+ (dispatch_time_t)dispatchTimeWithMilli:(NSUInteger)milli;

+ (uint64_t)convertMilliToNano:(NSUInteger)milli;

+ (void)finalizeAtRuntime:(nullable id<ADJRuntimeFinalizer>)runtimeFinalizer;

+ (nonnull NSArray<NSString *> *)pluginsClassNameList;

+ (nonnull NSString *)clientSdkWithPrefix:(nullable NSString *)sdkPrefix;

@end

