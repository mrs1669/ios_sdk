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

@interface ADJCoppaStateOutputData : NSObject
@property (nullable, readonly, strong, nonatomic) ADJCoppaStateData *changedStateData;

@property (readonly, assign, nonatomic) BOOL trackTPSbeforeDeactivate;
@property (readonly, assign, nonatomic) BOOL deactivateTPSafterTracking;
@property (readonly, assign, nonatomic) BOOL deactivateDeviceIds;

@end

@interface ADJCoppaState : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             initialStateData:(nonnull ADJCoppaStateData *)initialStateData;

// public api
- (nullable ADJCoppaStateOutputData *)
    sdkInitWithWasCoppaEnabledByClient:(BOOL)wasCoppaEnabledByClient;

@end
