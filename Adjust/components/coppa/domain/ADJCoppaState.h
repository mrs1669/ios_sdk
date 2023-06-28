//
//  ADJCoppaState.h
//  Adjust
//
//  Created by Pedro Silva on 28.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJCoppaStateData.h"

@interface ADJCoppaState : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             initialStateData:(nonnull ADJCoppaStateData *)initialStateData;

// public api
- (nullable ADJCoppaStateData *)
    sdkInitWithClientIsCoppaEnabled:(nullable ADJBooleanWrapper *)clientIsCoppaEnabled;

- (BOOL)shouldTrackTPSbeforeDeactivateWithChangedStateData:(nullable ADJCoppaStateData *)stateData;

- (BOOL)shouldDeactivateTPSafterTracking;

@end

