//
//  ADJTallyCounter.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPackageParamValueSerializable.h"
#import "ADJIoValueSerializable.h"
#import "ADJNonNegativeInt.h"
#import "ADJResultNL.h"
#import "ADJResultNN.h"

@interface ADJTallyCounter : NSObject<
    NSCopying,
    ADJPackageParamValueSerializable,
    ADJIoValueSerializable
>

// instantiation
+ (nonnull instancetype)instanceStartingAtZero;
+ (nonnull instancetype)instanceStartingAtOne;

+ (nullable instancetype)instanceFromOptionalNonNegativeInt:
    (nullable ADJNonNegativeInt *)nonNegativeInt;

+ (nonnull ADJResultNN<ADJTallyCounter *> *)
    instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue;

+ (nonnull ADJResultNL<ADJTallyCounter *> *)
    instanceFromOptionalIoDataValue:(nullable ADJNonEmptyString *)ioDataValue;

- (nonnull instancetype)initWithCountValue:(nonnull ADJNonNegativeInt *)countValue
NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readwrite, strong, nonatomic) ADJNonNegativeInt *countValue;

// public api
- (nonnull ADJTallyCounter *)generateIncrementedCounter;

@end
