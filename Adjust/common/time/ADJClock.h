//
//  ADJ5Clock.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJTimestampMilli.h"
#import "ADJLogger.h"
#import "ADJRelativeTimestamp.h"

@interface ADJClock : NSObject
// instantiation
- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;

// public api
- (nullable ADJTimestampMilli *)nonMonotonicNowTimestampMilliWithLogger:
    (nonnull ADJLogger *)logger;

- (nullable ADJRelativeTimestamp *)monotonicRelativeTimestamp;

@end
