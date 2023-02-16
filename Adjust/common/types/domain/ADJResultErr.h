//
//  ADJResultErr.h
//  Adjust
//
//  Created by Pedro Silva on 14.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJResultErr<S> : NSObject
// instantiation
- (nullable instancetype)init NS_UNAVAILABLE;

+ (nonnull ADJResultErr *)okWithValue:(nonnull S)value;
+ (nonnull ADJResultErr *)okWithoutValue;
+ (nonnull ADJResultErr *)failWithError:(nonnull NSError *)error;

// public properties
@property (nullable, readonly, strong, nonatomic) S value;
@property (nullable, readonly, strong, nonatomic) NSError *error;

@end
