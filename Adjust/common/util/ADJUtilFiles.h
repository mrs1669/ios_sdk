//
//  ADJUtilFiles.h
//  Adjust
//
//  Created by Pedro Silva on 25.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJResultNN.h"

@interface ADJUtilFiles : NSObject

+ (BOOL)fileExistsWithPath:(nonnull NSString *)path;

+ (nullable NSString *)filePathInDocumentsDir:(nonnull NSString *)fileName;

+ (nullable NSString *)filePathInAdjustAppSupportDir:(nonnull NSString *)filename;

+ (nonnull NSString *)filePathWithDir:(nonnull NSString *)dirPath
                             filename:(nonnull NSString *)filename;

+ (nullable NSString *)adjustAppSupportDir;

+ (nonnull ADJResultNN<NSNumber *> *)createDirWithPath:(nonnull NSString *)path;

@end
