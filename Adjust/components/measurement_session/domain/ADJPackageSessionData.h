//
//  ADJPackageSessionData.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJMeasurementSessionDataBuilder.h"
#import "ADJTallyCounter.h"
#import "ADJTimestampMilli.h"
#import "ADJTimeLengthMilli.h"

@interface ADJPackageSessionData : NSObject
// instantiation
- (nonnull instancetype)initWithBuilder:(nonnull ADJMeasurementSessionDataBuilder *)measurementSessionDataBuilder;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJTallyCounter *sessionCount;
@property (nullable, readonly, strong, nonatomic) ADJTimestampMilli *lastActivityTimestampMilli;
@property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *sessionLengthMilli;
@property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *timeSpentMilli;

@end
