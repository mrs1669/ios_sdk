//
//  ADJBackoffStrategy.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJNonNegativeInt.h"
#import "ADJTimeLengthMilli.h"

@interface ADJBackoffStrategy : NSObject
// instantiation
- (nonnull instancetype)initWithShortWait;
- (nonnull instancetype)initWithMediumWait;
- (nonnull instancetype)initWithLongWait;

// public api
- (nonnull ADJTimeLengthMilli *)calculateBackoffTimeWithRetries:
    (nonnull ADJNonNegativeInt *)retries;

@end
