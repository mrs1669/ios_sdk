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
+ (nullable NSString *)getFilePathInDocumentsDir:(nonnull NSString *)fileName {
    // TODO figure out if this is the "right" way
    //  like for example using NSFileManager URLsForDirectory:inDomains:
    NSArray *_Nonnull paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count == 0) {
        return nil;
    }
    
    NSString *_Nonnull documentsDirPath = [paths objectAtIndex:0];
    NSString *_Nonnull filePath = [documentsDirPath stringByAppendingPathComponent:fileName];
    
    return filePath;
}

+ (nullable NSString *)getFilePathInAppSupportDir:(NSString *)fileName {
    NSArray *_Nonnull paths =
    NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                        NSUserDomainMask,
                                        YES);
    if (paths.count == 0) {
        return nil;
    }
    
    NSString *_Nonnull appSupportDirPath = [paths objectAtIndex:0];
    NSString *_Nonnull adjustAppSupportDirPath =
    [appSupportDirPath stringByAppendingPathComponent:@"Adjust"];
    NSString *_Nonnull filePath =
    [adjustAppSupportDirPath stringByAppendingPathComponent:fileName];
    
    return filePath;
}

+ (BOOL)createAdjustAppSupportDir {
    // return value indicates if directory was created successfully or not
    // error won't be reported if directory already exists
    NSArray *_Nonnull paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                                                  NSUserDomainMask,
                                                                  YES);
    if (paths.count == 0) {
        return NO;
    }
    
    NSString *_Nonnull appSupportDirPath = [paths objectAtIndex:0];
    NSString *_Nonnull adjustAppSupportDirPath =
    [appSupportDirPath stringByAppendingPathComponent:@"Adjust"];
    NSError *_Nullable error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:adjustAppSupportDirPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        //NSLog(@"Error while creating directory: %@", adjustAppSupportDirPath);
        //NSLog(@"Error: %@", error);
        return NO;
    }
    
    return YES;
}

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
