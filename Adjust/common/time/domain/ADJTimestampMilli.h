//
//  ADJTimestampMilli.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoValueSerializable.h"
#import "ADJPackageParamValueSerializable.h"
#import "ADJTimeLengthMilli.h"
#import "ADJIoData.h"
#import "ADJNonEmptyString.h"
#import "ADJResultNL.h"
#import "ADJResultNN.h"

@interface ADJTimestampMilli : NSObject<NSCopying,
    ADJIoValueSerializable,
    ADJPackageParamValueSerializable
>
// instantiation
+ (nonnull ADJResultNL<ADJTimestampMilli *> *)
    instanceFromOptionalIoDataValue:(nullable ADJNonEmptyString *)ioDataValue;

+ (nonnull ADJResultNN<ADJTimestampMilli *> *)
    instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue;

+ (nonnull ADJResultNN<ADJTimestampMilli *> *)
    instanceWithNumberDoubleSecondsSince1970:(nullable NSNumber *)numberDoubleSecondsSince1970;
+ (nonnull ADJResultNN<ADJTimestampMilli *> *)
    instanceWithTimeIntervalSecondsSince1970:(NSTimeInterval)timeIntervalSecondsSince1970;

+ (nonnull ADJResultNL<ADJTimestampMilli *> *)
    instanceWithOptionalNumberDoubleSecondsSince1970:
        (nullable NSNumber *)numberDoubleSecondsSince1970;
/*
+ (nonnull ADJResultNN<ADJTimestampMilli *> *)
    instanceWithNSDateValue:(nullable NSDate *)nsDateValue;
*/
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJNonNegativeInt *millisecondsSince1970Int;

// public api
- (nullable ADJTimeLengthMilli *)timeLengthDifferenceWithLaterTimestamp:
    (nonnull ADJTimestampMilli *)laterTimestamp;

- (nonnull ADJTimeLengthMilli *)timeLengthDifferenceWithNonMonotonicNowTimestamp:
    (nonnull ADJTimestampMilli *)nonMonotonicNowTimestamp;

- (nonnull ADJTimestampMilli *)generateTimestampWithAddedTimeLength:
    (nonnull ADJTimeLengthMilli *)timeLengthToAdd;

- (nonnull NSString *)dateFormattedDescription;

@end
