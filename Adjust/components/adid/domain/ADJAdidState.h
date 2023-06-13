//
//  ADJAdidState.h
//  Adjust
//
//  Created by Pedro Silva on 13.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJAdidStateData.h"
#import "ADJNonEmptyString.h"

@interface ADJAdidState : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             initialStateData:(nonnull ADJAdidStateData *)initialStateData;

// public api
- (nullable ADJAdidStateData *)updateStateWithReceivedAdid:
    (nullable ADJNonEmptyString *)receivedAdid;

@end
