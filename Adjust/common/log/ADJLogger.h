//
//  ADJLogger.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJLogCollector.h"

@interface ADJLogger : NSObject
// instantiation
- (nonnull instancetype)initWithSource:(nonnull NSString *)source
                          logCollector:(nonnull id<ADJLogCollector>)logCollector
NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

@property (nonnull, readonly, strong, nonatomic) NSString *source;
// public API
- (nonnull NSString *)debug:(nonnull NSString *)message, ... NS_FORMAT_FUNCTION(1,2);
- (nonnull NSString *)debug:(nonnull NSString *)message parameters:(va_list)parameters;

- (nonnull NSString *)info:(nonnull NSString *)message, ... NS_FORMAT_FUNCTION(1,2);
- (nonnull NSString *)info:(nonnull NSString *)message parameters:(va_list)parameters;

- (nonnull NSString *)error:(nonnull NSString *)message, ... NS_FORMAT_FUNCTION(1,2);
- (nonnull NSString *)error:(nonnull NSString *)message parameters:(va_list)parameters;

- (nonnull NSString *)errorWithNSError:(nonnull NSError *)error
                               message:(nonnull NSString *)message, ... NS_FORMAT_FUNCTION(2,3);
- (nonnull NSString *)errorWithNSError:(nonnull NSError *)error
                               message:(nonnull NSString *)message
                            parameters:(va_list)parameters;

+ (nonnull NSString *)formatNSError:(nonnull NSError *)error
                            message:(nonnull NSString *)message;
@end
