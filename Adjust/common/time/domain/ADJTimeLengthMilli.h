//
//  ADJTimeLengthMilli.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPackageParamValueSerializable.h"
#import "ADJIoValueSerializable.h"
#import "ADJNonEmptyString.h"
#import "ADJNonNegativeInt.h"
#import "ADJResult.h"

@interface ADJTimeLengthMilli : NSObject<
    NSCopying,
    ADJPackageParamValueSerializable,
    ADJIoValueSerializable
>
// instantiation
+ (nonnull instancetype)instanceWithoutTimeSpan;
+ (nonnull instancetype)instanceWithOneMilliSpan;

+ (nonnull ADJResult<ADJTimeLengthMilli *> *)
    instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue;

+ (nonnull ADJResult<ADJTimeLengthMilli *> *)
    instanceWithNumberDoubleSeconds:(nullable NSNumber *)numberDoubleSeconds;

- (nonnull instancetype)initWithMillisecondsSpan:(nonnull ADJNonNegativeInt *)millisecondsSpan
NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJNonNegativeInt *millisecondsSpan;

// public api
- (nonnull ADJTimeLengthMilli *)generateTimeLengthWithAddedTimeLength:(nonnull ADJTimeLengthMilli *)timeLengthToAdd;

- (NSTimeInterval)secondsInterval;

- (nonnull NSString *)millisecondsDescription;

- (nonnull NSString *)secondsDescription;

- (BOOL)isZero;

- (BOOL)isMaxValue;

@end

