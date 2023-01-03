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
+ (nullable NSString *)filePathInDocumentsDir:(nonnull NSString *)fileName {
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

+ (nullable NSString *)filePathInAdjustAppSupportDir:(NSString *)fileName {

    NSString *_Nullable adjustAppSupportDirPath = [self adjustAppSupportDir];
    if (! adjustAppSupportDirPath) {
        return nil;
    }

    NSString *_Nonnull filePath =
    [adjustAppSupportDirPath stringByAppendingPathComponent:fileName];

    return filePath;
}

+ (nullable NSString *)adjustAppSupportDir {
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

    return adjustAppSupportDirPath;
}

+ (BOOL)createAdjustAppSupportDir {
    // return value indicates if directory was created successfully or not
    // error won't be reported if directory already exists

    NSString *_Nullable adjustAppSupportDirPath = [self adjustAppSupportDir];
    if (! adjustAppSupportDirPath) {
        return NO;
    }

    NSError *_Nullable error = nil;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:adjustAppSupportDirPath
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:&error];
    if (! success && error != nil) {
        // TODO: (Gena) - write these logs into an appropriate loger instance.
        //NSLog(@"Error while creating directory: %@", adjustAppSupportDirPath);
        //NSLog(@"Error: %@", error);
        return NO;
    }
    
    return YES;
}

+ (void)moveFromDocumentsToSupportFolderOldDbFilename:(nonnull NSString *)oldName
                                        newDbFileName:(nonnull NSString *)newName {
    NSString *oldFilePath = [self filePathInDocumentsDir:oldName];
    NSString *newFilePath = [self filePathInAdjustAppSupportDir:newName];

    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] moveItemAtPath:oldFilePath
                                                           toPath:newFilePath
                                                            error:&error];
    if (! success && error != nil) {
        // TODO: (Gena) - write these logs into an appropriate loger instance.
        //NSLog(@"%@", [error localizedDescription]);
    }
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
