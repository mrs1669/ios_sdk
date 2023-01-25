//
//  ADJUtilFiles.h
//  Adjust
//
//  Created by Pedro Silva on 25.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJUtilFiles : NSObject

+ (BOOL)fileExistsWithPath:(nonnull NSString *)path;

+ (nullable NSString *)filePathInDocumentsDir:(nonnull NSString *)fileName;

+ (nullable NSString *)filePathInAdjustAppSupportDirWithFilename:(nonnull NSString *)filename;

+ (nonnull NSString *)filePathWithDir:(nonnull NSString *)dirPath
                             filename:(nonnull NSString *)filename;

+ (nullable NSString *)adjustAppSupportDir;

+ (BOOL)createDirWithPath:(nonnull NSString *)path
                 errorPtr:(NSError * _Nullable * _Nonnull)errorPtr;

+ (BOOL)moveFileFromPath:(nonnull NSString *)fromPath
                  toPath:(nonnull NSString *)toPath
                errorPtr:(NSError * _Nullable * _Nonnull)errorPtr;

@end
