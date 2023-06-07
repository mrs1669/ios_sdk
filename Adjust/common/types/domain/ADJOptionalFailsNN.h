//
//  ADJOptionalFailsNN.h
//  Adjust
//
//  Created by Pedro Silva on 14.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJResultFail.h"

@interface ADJOptionalFailsNN<V> : NSObject
// public properties
@property (nonnull, readonly, strong, nonatomic) NSArray<ADJResultFail *> *optionalFails;
@property (nonnull, readonly, strong, nonatomic) V value;

// instantiation
- (nonnull instancetype)initWithOptionalFails:(nullable NSArray<ADJResultFail *> *)optionalFails
                                        value:(nonnull V)value;

- (nullable instancetype)init NS_UNAVAILABLE;

@end
