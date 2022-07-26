//
//  ADJValueWO.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJValueWO.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) V changedValue;
 @property (assign, readonly, nonatomic) BOOL valueChanged;
 */

@implementation ADJValueWO
#pragma mark Instantiation
- (nonnull instancetype)init {
    self = [super init];
    
    _changedValue = nil;
    _valueChanged = NO;
    
    return self;
}

#pragma mark Public API
- (void)setNewValue:(nonnull id)newValue {
    _changedValue = newValue;
    _valueChanged = YES;
}

@end

