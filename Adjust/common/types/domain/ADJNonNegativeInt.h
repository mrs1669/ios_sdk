//
//  ADJNonNegativeInt.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPackageParamValueSerializable.h"
#import "ADJIoValueSerializable.h"
#import "ADJNonEmptyString.h"
#import "ADJResult.h"

@interface ADJNonNegativeInt : NSObject<
    NSCopying,
    ADJPackageParamValueSerializable,
    ADJIoValueSerializable
>
// instantiation
+ (nonnull instancetype)instanceAtZero;
+ (nonnull instancetype)instanceAtOne;

+ (nonnull ADJResult<ADJNonNegativeInt *> *)
    instanceFromIntegerNumber:(nullable NSNumber *)integerNumber;

+ (nonnull ADJResult<ADJNonNegativeInt *> *)
    instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue;

- (nonnull instancetype)initWithUIntegerValue:(NSUInteger)uIntegerValue
    NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (readonly, assign, nonatomic) NSUInteger uIntegerValue;

// public api
- (nonnull ADJNonEmptyString *)toNonEmptyString;

// TODO: remove non-used integer comparison
- (NSComparisonResult)compare:(nonnull ADJNonNegativeInt *)nonNegativeInt;

- (BOOL)isZero;

- (BOOL)isMaxValue;

@end

