//
//  ATOAdjustTestOptions.h
//  AdjustTestApp
//
//  Created by Pedro S. on 07.05.21.
//  Copyright © 2021 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATOAdjustTestOptions : NSObject

+ (void)addToOptionsSetWithKey:(nonnull NSString *)key value:(nonnull NSString *)value;

+ (nullable NSString *)
    teardownAndApplyAddedTestOptionsSetWithUrlOverwrite:(nonnull NSString *)urlOverwrite;

+ (nullable NSString *)
    teardownAndExecuteTestOptionsCommandWithUrlOverwrite:(nonnull NSString *)urlOverwrite
    commandParameters:
        (nonnull NSDictionary<NSString *, NSArray<NSString* > *> *)commandParameters;

+ (nullable NSNumber *)strictParseNumberBooleanWithString:(nullable NSString *)stringValue;

@end
