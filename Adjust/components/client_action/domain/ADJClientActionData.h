//
//  ADJClientActionData.h
//  Adjust
//
//  Created by Genady Buchatsky on 29.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJNonEmptyString.h"
#import "ADJTimestampMilli.h"
#import "ADJIoDataBuilder.h"
#import "ADJIoData.h"
#import "ADJLogger.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJClientActionDataMetadataTypeValue;
FOUNDATION_EXPORT NSString *const ADJClientActionTypeKey;

NS_ASSUME_NONNULL_END

@interface ADJClientActionData : NSObject
// instantiation
+ (nonnull ADJResultNN<ADJClientActionData *> *)instanceWithIoData:(nonnull ADJIoData *)ioData;

- (nonnull instancetype)initWithClientActionHandlerId:(nonnull ADJNonEmptyString *)clientActionHandlerId
                                         nowTimestamp:(nonnull ADJTimestampMilli *)nowTimestamp
                                        ioDataBuilder:(nonnull ADJIoDataBuilder *)ioDataBuilder;
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *clientActionHandlerId;
@property (nonnull, readonly, strong, nonatomic) ADJTimestampMilli *apiTimestamp;
@property (nonnull, readonly, strong, nonatomic) ADJIoData *ioData;

@end


