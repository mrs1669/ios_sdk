//
//  ADJOptionalFailsNL.h
//  Adjust
//
//  Created by Pedro Silva on 17.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJResultFail.h"

@interface ADJOptionalFailsNL<V> : NSObject
// public properties
@property (nonnull, readonly, strong, nonatomic) NSArray<ADJResultFail *> *optionalFails;
@property (nullable, readonly, strong, nonatomic) V value;

// instantiation
- (nonnull instancetype)initWithOptionalFails:(nullable NSArray<ADJResultFail *> *)optionalFails
                                        value:(nullable V)value;

- (nullable instancetype)init NS_UNAVAILABLE;

@end
