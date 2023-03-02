//
//  ADJResultNN.h
//  Adjust
//
//  Created by Pedro Silva on 07.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJResultFail.h"
//@protocol ADJResultFail;

@interface ADJResultNN<S> : NSObject<ADJResultFail>
// instantiation
- (nullable instancetype)init NS_UNAVAILABLE;

+ (nonnull ADJResultNN<S> *)okWithValue:(nonnull S)value;

+ (nonnull ADJResultNN<S> *)failWithMessage:(nonnull NSString *)failMessage;
+ (nonnull ADJResultNN<S> *)failWithMessage:(nonnull NSString *)failMessage
                                        key:(nonnull NSString *)key
                                      value:(nullable id)value;
+ (nonnull ADJResultNN<S> *)failWithException:(nonnull NSException *)exception;
+ (nonnull ADJResultNN<S> *)failWithError:(nonnull NSError *)error
                                  message:(nullable NSString *)failMessage;

+ (nonnull ADJResultNN<S> *)
    failWithMessage:(nullable NSString *)failMessage
    failParams:(nullable NSDictionary<NSString *, id> *)failParams
    failError:(nullable NSError *)failError
    failException:(nullable NSException *)failException;

+ (nonnull NSDictionary<NSString *, id> *)generateFoundationDictionaryFromResultFail:
    (nonnull id<ADJResultFail>)resultFail;

// public properties
@property (nonnull, readonly, strong, nonatomic) S value;
@property (nullable, readonly, strong, nonatomic) id<ADJResultFail> fail;

@end

/*
 @property (nullable, readonly, strong, nonatomic) NSString *message;
 @property (nullable, readonly, strong, nonatomic) NSDictionary<NSString *, id> *params;
 @property (nullable, readonly, strong, nonatomic) NSError *error;
 @property (nullable, readonly, strong, nonatomic) NSException *exception;

 - (nonnull NSDictionary<NSString *, id> *)foundationDictionary;

 */
