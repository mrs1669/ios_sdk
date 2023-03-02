//
//  ADJSdkPackageSenderPinningDelegate.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJNonEmptyString.h"
#import "ADJSdkResponseDataBuilder.h"

@interface ADJSdkPackageSenderPinningDelegate : ADJCommonBase<NSURLSessionDelegate>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                publicKeyHash:(nonnull ADJNonEmptyString *)publicKeyHash;

@end
