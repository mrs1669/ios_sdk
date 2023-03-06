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

@interface ADJResultNN<V> : NSObject
// public properties
@property (nonnull, readonly, strong, nonatomic) V value;
@property (nullable, readonly, strong, nonatomic) ADJResultFail *fail;

// instantiation
- (nullable instancetype)init NS_UNAVAILABLE;

+ (nonnull ADJResultNN<V> *)okWithValue:(nonnull V)value;

+ (nonnull ADJResultNN<V> *)failWithMessage:(nonnull NSString *)failMessage;
+ (nonnull ADJResultNN<V> *)failWithMessage:(nonnull NSString *)failMessage
                                        key:(nonnull NSString *)key
                                      value:(nullable id)value;
+ (nonnull ADJResultNN<V> *)failWithMessage:(nonnull NSString *)failMessage
                                      error:(nullable NSError *)error;
+ (nonnull ADJResultNN<V> *)failWithMessage:(nonnull NSString *)failMessage
                                  exception:(nullable NSException *)exception;
+ (nonnull ADJResultNN<V> *)
    failWithMessage:(nonnull NSString *)failMessage
    builderBlock:(void (^ _Nonnull NS_NOESCAPE)(ADJResultFailBuilder *_Nonnull resultFailBuilder))
        builderBlock;

@end
