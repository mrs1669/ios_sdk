//
//  ADJRelativeTimestamp.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <sys/sysctl.h>
#include <time.h>
#import "ADJTimeLengthMilli.h"

@interface ADJRelativeTimestamp : NSObject

- (nonnull instancetype)initWithTimespec:(struct timespec)timespecValue;

- (nonnull instancetype)initWithTimeval:(struct timeval)timevalValue;


- (BOOL)hasEnoughTimePassedSince:(nonnull ADJRelativeTimestamp *)sinceTime
                enoughTimeLength:(nonnull ADJTimeLengthMilli *)enoughTimeLength;

@end
