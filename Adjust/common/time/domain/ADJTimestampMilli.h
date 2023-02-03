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
#import "ADJLogger.h"
#import "ADJIoData.h"
#import "ADJNonEmptyString.h"

@interface ADJTimestampMilli : NSObject<NSCopying,
    ADJIoValueSerializable,
    ADJPackageParamValueSerializable
>
// instantiation
+ (nullable instancetype)instanceFromOptionalIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
                                                  logger:(nonnull ADJLogger *)logger;
+ (nullable instancetype)instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
                                          logger:(nonnull ADJLogger *)logger;
+ (nullable instancetype)
    instanceWithTimeIntervalSecondsSince1970:(NSTimeInterval)timeIntervalSecondsSince1970
    logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)
    instanceWithOptionalNumberDoubleSecondsSince1970:
        (nullable NSNumber *)numberDoubleSecondsSince1970
    logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceWithNSDateValue:(nullable NSDate *)nsDateValue
                                          logger:(nonnull ADJLogger *)logger;

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
