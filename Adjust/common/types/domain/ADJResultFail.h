//
//  ADJResultFail.h
//  Adjust
//
//  Created by Pedro Silva on 01.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJResultFail : NSObject
// public properties
@property (nonnull, readonly, strong, nonatomic) NSString *message;
@property (nullable, readonly, strong, nonatomic) NSDictionary<NSString *, id> *params;
@property (nullable, readonly, strong, nonatomic) NSError *error;
@property (nullable, readonly, strong, nonatomic) NSException *exception;

// instantiation
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                 params:(nullable NSDictionary<NSString *, id> *)params
                                  error:(nullable NSError *)error
                              exception:(nullable NSException *)exception;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (nonnull NSDictionary<NSString *, id> *)foundationDictionary;

@end

@interface ADJResultFailBuilder : NSObject
// instantiation
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)withError:(nonnull NSError *)error;
- (void)withException:(nonnull NSException *)exception;
- (void)withKey:(nonnull NSString *)key
          value:(nullable id)value;

- (nonnull ADJResultFail *)build;

@end
