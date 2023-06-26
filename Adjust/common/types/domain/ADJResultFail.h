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
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message;
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                    key:(nonnull NSString *)key
                            stringValue:(nonnull NSString *)stringValue;
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                    key:(nonnull NSString *)key
                              otherFail:(nonnull ADJResultFail *)otherFail;
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                  error:(nullable NSError *)error;
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                              exception:(nullable NSException *)exception;

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message
                                 params:(nullable NSDictionary<NSString *, id> *)params
                                  error:(nullable NSError *)error
                              exception:(nullable NSException *)exception
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (nonnull NSDictionary<NSString *, id> *)toJsonDictionary;

@end

@interface ADJResultFailBuilder : NSObject
// instantiation
- (nonnull instancetype)initWithMessage:(nonnull NSString *)message;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)withError:(nonnull NSError *)error;
- (void)withException:(nonnull NSException *)exception;
- (void)withKey:(nonnull NSString *)key
      otherFail:(nonnull ADJResultFail *)otherFail;
- (void)withKey:(nonnull NSString *)key
    stringValue:(nonnull NSString *)stringValue;

- (nonnull ADJResultFail *)build;

@end
