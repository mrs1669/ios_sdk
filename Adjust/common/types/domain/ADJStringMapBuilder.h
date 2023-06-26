//
//  ADJStringMapBuilder.h
//  AdjustV5
//
//  Created by Pedro S. on 13.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJNonEmptyString.h"

@class ADJStringMap;

@interface ADJStringMapBuilder : NSObject<NSCopying>
// instantiation
- (nonnull instancetype)initWithEmptyMap;
- (nonnull instancetype)initWithStringMap:(nonnull ADJStringMap *)stringMap;
- (nullable instancetype)init NS_UNAVAILABLE;

// public api  
- (nullable ADJNonEmptyString *)addPairWithValue:(nonnull ADJNonEmptyString *)value
                                             key:(nonnull NSString *)key;

- (nullable ADJNonEmptyString *)addPairWithConstValue:(nonnull NSString *)constValue
                                                  key:(nonnull NSString *)key;

- (nullable ADJNonEmptyString *)pairValueWithKey:(nonnull NSString *)key;

- (nullable ADJNonEmptyString *)removePairWithKey:(nonnull NSString *)key;

- (void)addAllPairsWithStringMap:(nonnull ADJStringMap *)stringMap;

- (void)addAllPairsWithStringMapBuilder:(nonnull ADJStringMapBuilder *)stringMapBuilder;

- (NSUInteger)countPairs;

- (BOOL)isEmpty;

- (nonnull NSDictionary<NSString *, ADJNonEmptyString*> *)mapCast;

@end
