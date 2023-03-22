//
//  ADJEventDeduplicationController.h
//  Adjust
//
//  Created by Aditi Agrawal on 02/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJCommonBase.h"
#import "ADJEventDeduplicationStorage.h"
#import "ADJNonNegativeInt.h"

@interface ADJEventDeduplicationController : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                    eventDeduplicationStorage:(nonnull ADJEventDeduplicationStorage *)eventDeduplicationStorage
                maxCapacityEventDeduplication:(nullable ADJNonNegativeInt *)maxCapacityEventDeduplication;

// public api
- (BOOL)ccContainsDeduplicationId:(nonnull ADJNonEmptyString *)deduplicationId;

- (nonnull ADJNonNegativeInt *)ccAddDeduplicationId:(nonnull ADJNonEmptyString *)deduplicationId;

@end
