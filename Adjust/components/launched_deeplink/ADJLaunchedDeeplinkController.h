//
//  ADJLaunchedDeeplinkController.h
//  Adjust
//
//  Created by Aditi Agrawal on 08/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJClientActionHandler.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJMainQueueController.h"
#import "ADJClientLaunchedDeeplinkData.h"
#import "ADJLaunchedDeeplinkStateStorage.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJLaunchedDeeplinkClientActionHandlerId;

NS_ASSUME_NONNULL_END

@interface ADJLaunchedDeeplinkController : ADJCommonBase <ADJClientActionHandler>
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    launchedDeeplinkStateStorage:
        (nonnull ADJLaunchedDeeplinkStateStorage *)launchedDeeplinkStateStorage
    mainQueueController:(nonnull ADJMainQueueController *)mainQueueController;

// public api
- (void)ccTrackLaunchedDeeplinkWithClientData:(nonnull ADJClientLaunchedDeeplinkData *)clientLaunchedDeeplinkData;

@end

