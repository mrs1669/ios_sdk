//
//  ADJDelayData.h
//  Adjust
//
//  Created by Aditi Agrawal on 26/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJTimeLengthMilli.h"

@interface ADJDelayData : NSObject
// instantiation
- (nonnull instancetype)initWithDelay:(nonnull ADJTimeLengthMilli *)delay
                                 from:(nonnull NSString *)from
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *delay;
@property (nonnull, readonly, strong, nonatomic) NSString *from;

@end
