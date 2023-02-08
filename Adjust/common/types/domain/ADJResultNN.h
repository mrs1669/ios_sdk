//
//  ADJResultNN.h
//  Adjust
//
//  Created by Pedro Silva on 07.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJResultNN<S> : NSObject
// instantiation
- (nullable instancetype)init NS_UNAVAILABLE;

+ (nonnull ADJResultNN<S> *)okWithValue:(nonnull S)value;
+ (nonnull ADJResultNN<S> *)failWithMessage:(nonnull NSString *)failMessage;

// public properties
@property (nonnull, readonly, strong, nonatomic) S value;
@property (nullable, readonly, strong, nonatomic) NSString *failMessage;

// public api
- (void)okBlock:(void (^ _Nonnull NS_NOESCAPE)(S _Nonnull value))okBlock
      failBlock:(void (^ _Nonnull NS_NOESCAPE)(NSString *_Nonnull failMessage))failBlock;

@end
