//
//  ADJKeychainStorage.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJNonEmptyString.h"
// TODO move to generic storage Component
@interface ADJKeychainStorage : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory;

// public api
- (nullable ADJNonEmptyString *)valueInGenericPasswordKeychainWithKey:(nonnull NSString *)key
                                                              service:(nonnull NSString *)service;
- (BOOL)setGenericPasswordKeychainWithKey:(nonnull NSString *)key
                                  service:(nonnull NSString *)service
                                    value:(nonnull ADJNonEmptyString *)value;

@end

