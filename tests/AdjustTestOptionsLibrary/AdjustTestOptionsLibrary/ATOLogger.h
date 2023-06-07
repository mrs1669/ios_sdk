//
//  ATOLogger.h
//  AdjustTestApp
//
//  Created by Pedro S. on 28.05.21.
//  Copyright © 2021 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATOLogger : NSObject

+ (void)log:(nonnull NSString *)message;

+ (void)log:(nonnull NSString *)message
        key:(nonnull NSString *)key
      value:(nonnull NSString *)value;

+ (void)log:(nonnull NSString *)message
   failDict:(nonnull NSDictionary<NSString *, id> *)failDict;

@end
