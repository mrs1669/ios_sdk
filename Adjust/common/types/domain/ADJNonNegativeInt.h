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
#import "ADJLogger.h"
#import "ADJNonEmptyString.h"

@interface ADJNonNegativeInt : NSObject<
    NSCopying,
    ADJPackageParamValueSerializable,
    ADJIoValueSerializable
>
// instantiation
+ (nonnull instancetype)instanceAtZero;
+ (nonnull instancetype)instanceAtOne;

+ (nullable instancetype)instanceFromIntegerNumber:(nullable NSNumber *)integerNumber
                                        logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromOptionalIntegerNumber:(nullable NSNumber *)integerNumber
                                                logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
                                          logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromOptionalIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
                                                  logger:(nonnull ADJLogger *)logger;

- (nonnull instancetype)initWithUIntegerValue:(NSUInteger)uIntegerValue
    NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (readonly, assign, nonatomic) NSUInteger uIntegerValue;

// public api
- (nonnull ADJNonEmptyString *)toNonEmptyString;

- (NSComparisonResult)compare:(nonnull ADJNonNegativeInt *)nonNegativeInt;

- (BOOL)isZero;

- (BOOL)isMaxValue;

@end

