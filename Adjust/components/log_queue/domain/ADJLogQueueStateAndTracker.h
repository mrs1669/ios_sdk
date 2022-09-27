//
//  ADJLogQueueStateAndTracker.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJDelayData.h"
#import "ADJCommonBase.h"
#import "ADJBackoffStrategy.h"
#import "ADJLogPackageData.h"
#import "ADJSdkResponseData.h"

@interface ADJQueueResponseProcessingData : NSObject
// instantiation
- (nonnull instancetype)initWithRemovePackageAtFront:(BOOL)removePackageAtFront
                                           delayData:(nonnull ADJDelayData *)delayData
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (readonly, assign, nonatomic) BOOL removePackageAtFront;
@property (nonnull, readonly, strong, nonatomic) ADJDelayData * delayData;

@end

@interface ADJLogQueueStateAndTracker : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              backoffStrategy:(nonnull ADJBackoffStrategy *)backoffStrategy;

// public api
- (BOOL)sendWhenSdkInitWithHasPackageAtFront:(BOOL)hasPackageAtFront;

- (BOOL)sendWhenLogPackageAddedWithData:(nonnull ADJLogPackageData *)logPackageDataToAdd
                      packageQueueCount:(nonnull ADJNonNegativeInt *)queueSdkPackageCount
                      hasPackageAtFront:(BOOL)hasPackageAtFront;

- (BOOL)sendWhenResumeSendingWithHasPackageAtFront:(BOOL)hasPackageAtFront;

- (void)pauseSending;

- (BOOL)sendWhenDelayEndedWithHasPackageAtFront:(BOOL)hasPackageAtFront;

- (nonnull ADJQueueResponseProcessingData *)processReceivedSdkResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponse;

- (BOOL)sendAfterProcessingSdkResponseWithHasPackageAtFront:(BOOL)hasPackageAtFront;

- (nonnull ADJNonNegativeInt *)retriesSinceLastSuccessSend;

@end
