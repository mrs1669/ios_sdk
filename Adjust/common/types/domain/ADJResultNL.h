//
//  ADJResultNL.h
//  Adjust
//
//  Created by Pedro Silva on 07.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJResultNN.h"
//@class ADJResultNN;
#import "ADJResultFail.h"
//@protocol ADJResultFail;

@interface ADJResultNL<S> : NSObject<ADJResultFail>
// instantiation
- (nullable instancetype)init NS_UNAVAILABLE;

+ (nonnull ADJResultNL<S> *)okWithValue:(nonnull S)value;
+ (nonnull ADJResultNL<S> *)okWithoutValue;

+ (nonnull ADJResultNL<S> *)failWithMessage:(nonnull NSString *)failMessage;
+ (nonnull ADJResultNL<S> *)failWithMessage:(nonnull NSString *)failMessage
                                        key:(nonnull NSString *)key
                                      value:(nullable id)value;
+ (nonnull ADJResultNL<S> *)failWithException:(nonnull NSException *)exception;
+ (nonnull ADJResultNL<S> *)failWithError:(nonnull NSError *)error
                                  message:(nullable NSString *)failMessage;

+ (nonnull ADJResultNL<S> *)
    failWithMessage:(nullable NSString *)failMessage
    failParams:(nullable NSDictionary<NSString *, id> *)failParams
    failError:(nullable NSError *)failError
    failException:(nullable NSException *)failException;

+ (nonnull id<ADJResultFail>)resultFailWithError:(nonnull NSError *)error
                                         message:(nullable NSString *)failMessage;


+ (nonnull ADJResultNL<S> *)instanceFromNN:
    (ADJResultNN<S> *_Nonnull (^ _Nonnull NS_NOESCAPE)(S _Nullable value))nnBlock
                                   nlValue:(nullable S)nlValue;

// public properties
@property (nullable, readonly, strong, nonatomic) S value;
@property (nullable, readonly, strong, nonatomic) id<ADJResultFail> fail;

@end
