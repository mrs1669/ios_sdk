//
//  ADJEventController.h
//  Adjust
//
//  Created by Genady Buchatsky on 29.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJClientActionHandler.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJEventStateStorage.h"
#import "ADJEventDeduplicationStorage.h"
#import "ADJMainQueueController.h"
#import "ADJNonNegativeInt.h"
#import "ADJClientEventData.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJEventControllerClientActionHandlerId;

NS_ASSUME_NONNULL_END

@interface ADJEventController : ADJCommonBase <ADJClientActionHandler>
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    eventStateStorage:(nonnull ADJEventStateStorage *)eventStateStorage
    eventDeduplicationStorage:(nonnull ADJEventDeduplicationStorage *)eventDeduplicationStorage
    mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
    maxCapacityEventDeduplication:(nonnull ADJNonNegativeInt *)maxCapacityEventDeduplication;

// public api
- (void)ccTrackEventWithClientData:(nonnull ADJClientEventData *)clientEventData;

@end
