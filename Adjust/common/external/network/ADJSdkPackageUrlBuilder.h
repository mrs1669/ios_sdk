//
//  ADJSdkPackageUrlBuilder.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJNonEmptyString.h"
#import "ADJStringMapBuilder.h"
#import "ADJAdjustConfig.h"


@interface ADJSdkPackageUrlBuilder : NSObject
// instantiation
- (nonnull instancetype)initWithUrlOverwrite:(nullable NSString *)urlOverwrite
                                   extraPath:(nullable NSString *)extraPath
                       urlStrategyBaseDomain:(nullable ADJNonEmptyString *)urlStrategyBaseDomain
                               dataResidency:(nullable AdjustDataResidency)dataResidency
                     clientCustomEndpointUrl:(nullable ADJNonEmptyString *)clientCustomEndpointUrl;

// public api
- (nonnull NSString *)targetUrlWithPath:(nonnull NSString *)path
                      sendingParameters:(nonnull ADJStringMapBuilder *)sendingParameters;

- (BOOL)shouldRetryAfterNetworkFailure;

- (void)resetAfterNetworkNotFailing;

- (nonnull NSString *)defaultTargetUrl;

- (NSUInteger)urlCountWithPath:(nonnull NSString *)path;

@end

