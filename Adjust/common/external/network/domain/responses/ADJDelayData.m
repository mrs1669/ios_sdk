//
//  ADJDelayData.m
//  Adjust
//
//  Created by Aditi Agrawal on 26/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJDelayData.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *delay;
 @property (nonnull, readonly, strong, nonatomic) NSString *from;
 */

@implementation ADJDelayData
#pragma mark Instantiation
- (nonnull instancetype)initWithDelay:(nonnull ADJTimeLengthMilli *)delay
                                 from:(nonnull NSString *)from
{
    self = [super init];
    
    _delay = delay;
    _from = from;
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

