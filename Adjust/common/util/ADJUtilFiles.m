//
//  ADJUtilFiles.m
//  Adjust
//
//  Created by Pedro Silva on 25.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJUtilFiles.h"

#import "ADJConstantsSys.h"

@implementation ADJUtilFiles

+ (BOOL)fileExistsWithPath:(nonnull NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (nullable NSString *)filePathInAdjustAppSupportDir:(nonnull NSString *)filename {
    NSString *_Nullable adjustAppSupportDir = [ADJUtilFiles adjustAppSupportDir];
    if (adjustAppSupportDir == nil) { return nil; }

    return [ADJUtilFiles filePathWithDir:adjustAppSupportDir filename:filename];
}

+ (nonnull NSString *)filePathWithDir:(nonnull NSString *)dirPath
                             filename:(nonnull NSString *)filename
{
    return [dirPath stringByAppendingPathComponent:filename];
}

+ (nullable NSString *)filePathInDocumentsDir:(nonnull NSString *)fileName {
    // TODO: figure out if this is the "right" way
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

+ (nullable NSString *)adjustAppSupportDir {
    return [ADJUtilFiles appSupportDirWithPath:ADJAdjustDirPath];
}

+ (nullable NSString *)appSupportDirWithPath:(nonnull NSString *)path {
    NSArray *_Nonnull paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                                                  NSUserDomainMask,
                                                                  YES);
    if (paths.count == 0) {
        return nil;
    }

    NSString *_Nonnull appSupportDirPathBase = [paths objectAtIndex:0];
    return [appSupportDirPathBase stringByAppendingPathComponent:path];
}

+ (BOOL)createDirWithPath:(nonnull NSString *)path
                 errorPtr:(NSError * _Nullable * _Nonnull)errorPtr
{
    return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:errorPtr];
}
@end
