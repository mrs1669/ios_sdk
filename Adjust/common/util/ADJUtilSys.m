//
//  ADJUtilSys.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJUtilSys.h"

#import "ADJConstantsSys.h"

@implementation ADJUtilSys

#pragma mark Public API

+ (nonnull ADJNonEmptyString *)generateUuid {
    return [[ADJNonEmptyString alloc] initWithConstStringValue:
            [[[NSUUID UUID] UUIDString] lowercaseString]];
}

+ (dispatch_time_t)dispatchTimeWithMilli:(NSUInteger)milli {
    return dispatch_time(DISPATCH_TIME_NOW, [self convertMilliToNano:milli]);
}

+ (uint64_t)convertMilliToNano:(NSUInteger)milli {
    return milli * NSEC_PER_MSEC;
}

+ (void)finalizeAtRuntime:(nullable id<ADJRuntimeFinalizer>)runtimeFinalizer {
    if (runtimeFinalizer == nil) {
        return;
    }
    
    [runtimeFinalizer finalizeAtRuntime];
}

+ (nonnull NSArray<NSString *> *)pluginsClassNameList {
    return [[NSArray alloc] initWithObjects:ADJPluginSignerClassName, nil];
}

#pragma mark - Private methods

@end
