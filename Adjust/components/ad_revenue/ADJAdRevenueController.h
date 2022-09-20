//
//  ADJAdRevenueController.h
//  Adjust
//
//  Created by Aditi Agrawal on 23/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJClientActionHandler.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJMainQueueController.h"
#import "ADJClientAdRevenueData.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJAdRevenueControllerClientActionHandlerId;

NS_ASSUME_NONNULL_END

@interface ADJAdRevenueController : ADJCommonBase <ADJClientActionHandler>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController;

// public api
- (void)ccTrackAdRevenueWithClientData:(nonnull ADJClientAdRevenueData *)clientAdRevenueData;

@end

