//
//  ADJValueWO.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJValueWO<V> : NSObject
// instantiation
- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;

// public api
- (void)setNewValue:(nonnull V)newValue;

// public properties
@property (nullable, readonly, strong, nonatomic) V changedValue;
@property (assign, readonly, nonatomic) BOOL valueChanged;

@end

