//
//  ADJMainQueueStateAndTracker.h
//  Adjust
//
//  Created by Aditi Agrawal on 26/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJBackoffStrategy.h"
#import "ADJSdkPackageData.h"
#import "ADJNonNegativeInt.h"
#import "ADJDelayData.h"
#import "ADJSdkResponseData.h"

@interface ADJMainQueueResponseProcessingData : NSObject
// instantiation
- (nonnull instancetype)initWithRemovePackageAtFront:(BOOL)removePackageAtFront
                                           delayData:(nonnull ADJDelayData *)delayData
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (readonly, assign, nonatomic) BOOL removePackageAtFront;
@property (nonnull, readonly, strong, nonatomic) ADJDelayData * delayData;

@end

@interface ADJMainQueueStateAndTracker : ADJCommonBase
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    backoffStrategy:(nonnull ADJBackoffStrategy *)backoffStrategy;

// public api
- (BOOL)sendWhenSdkInitWithHasPackageAtFront:(BOOL)hasPackageAtFront;

- (BOOL)sendWhenPackageAddedWithPackage:(nonnull id<ADJSdkPackageData>)sdkPackageAdded
               mainQueueSdkPackageCount:(nonnull ADJNonNegativeInt *)mainQueueSdkPackageCount
                      hasPackageAtFront:(BOOL)hasPackageAtFront;

- (BOOL)sendWhenResumeSendingWithHasPackageAtFront:(BOOL)hasPackageAtFront;

- (void)pauseSending;

- (BOOL)sendWhenDelayEndedWithHasPackageAtFront:(BOOL)hasPackageAtFront;

- (nonnull ADJMainQueueResponseProcessingData *)
    processReceivedSdkResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponse;

- (BOOL)sendAfterProcessingSdkResponseWithHasPackageAtFront:(BOOL)hasPackageAtFront;

- (nonnull ADJNonNegativeInt *)retriesSinceLastSuccessSend;

@end

