//
//  ADJResultNL.h
//  Adjust
//
//  Created by Pedro Silva on 07.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJResultNN.h"

@interface ADJResultNL<S> : NSObject
// instantiation
- (nullable instancetype)init NS_UNAVAILABLE;

+ (nonnull ADJResultNL<S> *)okWithValue:(nonnull S)value;
+ (nonnull ADJResultNL<S> *)okWithoutValue;
+ (nonnull ADJResultNL<S> *)failWithMessage:(nonnull NSString *)failMessage;

+ (nonnull ADJResultNL<S> *)instanceFromNN:
    (ADJResultNN<S> *_Nonnull (^ _Nonnull NS_NOESCAPE)(S _Nullable value))nnBlock
                                   nlValue:(nullable S)nlValue;

// public properties
@property (nullable, readonly, strong, nonatomic) S value;
@property (nullable, readonly, strong, nonatomic) NSString *failMessage;

// public api
- (void)okBlock:(void (^ _Nonnull NS_NOESCAPE)(S _Nullable value))okBlock
      failBlock:(void (^ _Nonnull NS_NOESCAPE)(NSString *_Nonnull failMessage))failBlock;

@end
