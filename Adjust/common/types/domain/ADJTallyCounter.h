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

+ (nullable instancetype)instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
                                          logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromOptionalIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
                                                  logger:(nonnull ADJLogger *)logger;

- (nonnull instancetype)initWithCountValue:(nonnull ADJNonNegativeInt *)countValue
    NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readwrite, strong, nonatomic) ADJNonNegativeInt *countValue;

// public api
- (nonnull ADJTallyCounter *)generateIncrementedCounter;

@end
