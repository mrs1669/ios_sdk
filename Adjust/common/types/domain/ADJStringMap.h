//
//  ADJStringMap.h
//  Adjust
//
//  Created by Aditi Agrawal on 18/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPackageParamValueSerializable.h"
#import "ADJStringMapBuilder.h"
#import "ADJNonEmptyString.h"

@interface ADJStringMap : NSObject<ADJPackageParamValueSerializable>
// instantiation
- (nonnull instancetype)initWithStringMapBuilder:(nonnull ADJStringMapBuilder *)stringMapBuilder;
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readwrite, strong, nonatomic) NSDictionary<NSString *, ADJNonEmptyString *> *map;

// public api
- (nullable ADJNonEmptyString *)pairValueWithKey:(nonnull NSString *)key;

- (NSUInteger)countPairs;

- (BOOL)isEmpty;

- (nonnull NSDictionary<NSString *, NSString *> *)foundationStringMap;

@end
