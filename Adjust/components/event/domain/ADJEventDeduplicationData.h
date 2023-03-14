//
//  ADJEventDeduplicationData.h
//  Adjust
//
//  Created by Aditi Agrawal on 02/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataSerializable.h"
#import "ADJIoData.h"
#import "ADJNonEmptyString.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJEventDeduplicationDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJEventDeduplicationData : NSObject<ADJIoDataSerializable>
// instantiation
+ (nonnull ADJResultNN<ADJEventDeduplicationData *> *)
    instanceFromIoData:(nonnull ADJIoData *)ioData;

- (nonnull instancetype)initWithDeduplicationId:(nonnull ADJNonEmptyString *)deduplicationId;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *deduplicationId;

@end
