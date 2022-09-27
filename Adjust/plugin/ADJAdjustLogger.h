//
//  ADJAdjustLogger.h
//  Adjust
//
//  Created by Pedro S. on 15.09.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ADJAdjustLogger <NSObject>

- (nonnull NSString *)debug:(nonnull NSString *)message, ... NS_FORMAT_FUNCTION(1,2);

- (nonnull NSString *)info:(nonnull NSString *)message, ... NS_FORMAT_FUNCTION(1,2);

- (nonnull NSString *)error:(nonnull NSString *)message, ... NS_FORMAT_FUNCTION(1,2);

- (nonnull NSString *)errorWithNSError:(nonnull NSError *)error
                               message:(nonnull NSString *)message, ... NS_FORMAT_FUNCTION(2,3);

@end
