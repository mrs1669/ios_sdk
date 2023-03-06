//
//  ADJResultNL.h
//  Adjust
//
//  Created by Pedro Silva on 07.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJResultNN.h"
#import "ADJResultFail.h"

@interface ADJResultNL<V> : NSObject
// instantiation
- (nullable instancetype)init NS_UNAVAILABLE;

+ (nonnull ADJResultNL<V> *)okWithValue:(nonnull V)value;
+ (nonnull ADJResultNL<V> *)okWithoutValue;

+ (nonnull ADJResultNL<V> *)failWithMessage:(nonnull NSString *)failMessage;
+ (nonnull ADJResultNL<V> *)failWithMessage:(nonnull NSString *)failMessage
                                        key:(nonnull NSString *)key
                                      value:(nullable id)value;
+ (nonnull ADJResultNL<V> *)failWithMessage:(nonnull NSString *)failMessage
                                      error:(nullable NSError *)error;
+ (nonnull ADJResultNL<V> *)failWithMessage:(nonnull NSString *)failMessage
                                  exception:(nullable NSException *)exception;
+ (nonnull ADJResultNL<V> *)
    failWithMessage:(nonnull NSString *)failMessage
    builderBlock:(void (^ _Nonnull NS_NOESCAPE)(ADJResultFailBuilder *_Nonnull resultFailBuilder))
        builderBlock;

+ (nonnull ADJResultNL<V> *)instanceFromNN:
    (ADJResultNN<V> *_Nonnull (^ _Nonnull NS_NOESCAPE)(V _Nullable value))nnBlock
                                   nlValue:(nullable V)nlValue;

// public properties
@property (nullable, readonly, strong, nonatomic) V value;
@property (nullable, readonly, strong, nonatomic) ADJResultFail *fail;

@end
