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
#import "ADJResult.h"

@interface ADJTimestampMilli : NSObject<NSCopying,
    ADJIoValueSerializable,
    ADJPackageParamValueSerializable
>
// instantiation
+ (nonnull ADJResult<ADJTimestampMilli *> *)
    instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue;

+ (nonnull ADJResult<ADJTimestampMilli *> *)
    instanceWithNumberDoubleSecondsSince1970:(nullable NSNumber *)numberDoubleSecondsSince1970;
+ (nonnull ADJResult<ADJTimestampMilli *> *)
    instanceWithTimeIntervalSecondsSince1970:(NSTimeInterval)timeIntervalSecondsSince1970;

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
