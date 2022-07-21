//
//  ADJEntryRoot.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

#import "ADJTeardownFinalizer.h"
#import "ADJSdkConfigDataBuilder.h"
#import "ADJThreadController.h"
#import "ADJSingleThreadExecutor.h"
#import "ADJLogger.h"
#import "ADJPreSdkInitRootController.h"
//#import "ADJPostSdkInitRootController.h"
#import "ADJClientAPI.h"
#import "ADJClientConfigData.h"
#import "ADJLogController.h"
#import "ADJSdkConfigData.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJPublishingGateSubscriber.h"
#import "ADJClientReturnExecutor.h"

@interface ADJEntryRoot : NSObject
// subscriptions
- (void)
    ccSubscribeAndSetPostSdkInitDependenciesWithSdkInitPublisher:
        (nonnull ADJSdkInitPublisher *)sdkInitPublisher
    publishingGatePublisher:(nonnull ADJPublishingGatePublisher *)publishingGatePublisher;

// instantiation
- (nonnull instancetype)initWithSdkConfigDataBuilder:
    (nullable ADJSdkConfigDataBuilder *)sdkConfigDataBuilder NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJLogController *logController;
@property (nonnull, readonly, strong, nonatomic) ADJThreadController *threadController;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *clientExecutor;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *commonExecutor;
@property (nonnull, readonly, strong, nonatomic) ADJLogger *adjustApiLogger;
@property (nonnull, readonly, strong, nonatomic) ADJSdkConfigData *sdkConfigData;

// - built in client context
@property (nullable, readonly, strong, nonatomic)
    ADJPreSdkInitRootController *preSdkInitRootController;
//@property (nullable, readonly, strong, nonatomic)
//    ADJPostSdkInitRootController *postSdkInitRootController;

// public api
+ (void)executeBlockInClientContext:
    (nonnull void (^)(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger))
        blockInClientContext;

//- (nonnull ADJPostSdkInitRootController *)
//    ccCreatePostSdkInitRootControllerWithClientConfigData:
//        (nonnull ADJClientConfigData *)clientConfigData
//    preSdkInitRootController:(nonnull ADJPreSdkInitRootController *)preSdkInitRootController;

- (nonnull id<ADJClientReturnExecutor>)clientReturnExecutor;

- (void)finalizeAtTeardownWithCloseStorageBlock:(nullable void (^)(void))closeStorageBlock;

@end

