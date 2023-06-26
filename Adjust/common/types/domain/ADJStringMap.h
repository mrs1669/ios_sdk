//
//  ADJStringMap.h
//  Adjust
//
//  Created by Aditi Agrawal on 18/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPackageParamValueSerializable.h"
#import "ADJIoValueSerializable.h"
#import "ADJStringMapBuilder.h"
#import "ADJNonEmptyString.h"
#import "ADJResult.h"

@interface ADJStringMap : NSObject<
    ADJPackageParamValueSerializable,
    ADJIoValueSerializable
>
// instantiation
- (nonnull instancetype)initWithStringMapBuilder:(nonnull ADJStringMapBuilder *)stringMapBuilder;
- (nullable instancetype)init NS_UNAVAILABLE;

+ (nonnull ADJResult<ADJStringMap *> *)
    instanceFromIoValue:(nullable ADJNonEmptyString *)ioValue;

// public properties
@property (nonnull, readwrite, strong, nonatomic)
    NSDictionary<NSString *, ADJNonEmptyString *> *map;

// public api
- (nullable ADJNonEmptyString *)pairValueWithKey:(nonnull NSString *)key;

- (NSUInteger)countPairs;

- (BOOL)isEmpty;

- (nonnull NSDictionary<NSString *, NSString *> *)jsonStringDictionary;

@end
