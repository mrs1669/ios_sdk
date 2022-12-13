//
//  ADJClientCallbacksController.m
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientCallbacksController.h"

#import "ADJSessionDeviceIdsData.h"
#import "ADJUtilF.h"
#import "ADJConsoleLogger.h"
#import "ADJAdjustLogMessageData.h"

@interface ADJClientCallbacksController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJAttributionStateStorage *attributionStateStorageWeak;
@property (nullable, readonly, weak, nonatomic) id<ADJClientReturnExecutor> clientReturnExecutorWeak;
@property (nullable, readonly, weak, nonatomic) ADJDeviceController *deviceControllerWeak;

@end

@implementation ADJClientCallbacksController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                      attributionStateStorage:(nonnull ADJAttributionStateStorage *)attributionStateStorage
                         clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
                             deviceController:(nonnull ADJDeviceController *)deviceController {
    self = [super initWithLoggerFactory:loggerFactory source:@"ClientCallbacksController"];
    _attributionStateStorageWeak = attributionStateStorage;
    _clientReturnExecutorWeak = clientReturnExecutor;
    _deviceControllerWeak = deviceController;

    return self;
}

#pragma mark Public API
- (void)ccAttributionWithCallback:
    (nonnull id<ADJAdjustAttributionCallback>)adjustAttributionCallback
{
    id<ADJClientReturnExecutor> clientReturnExecutor = self.clientReturnExecutorWeak;
    if (clientReturnExecutor == nil) {
        [self.logger debugDev:
         @"Cannot return attribution in callback without a client return executor"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJAttributionStateStorage *_Nullable attributionStateStorage =
        self.attributionStateStorageWeak;
    if (attributionStateStorage == nil) {
        [self.logger debugDev:@"Cannot get attribution state without reference to storage"
                    issueType:ADJIssueWeakReference];
        [clientReturnExecutor executeClientReturnWithBlock:^{
            [adjustAttributionCallback unableToReadAdjustAttributionWithMessage:
                 @"Cannot get attribution data"
                 " because it was unexpectedly unable to access the storage"];
        }];
        return;
    }

    ADJAttributionStateData *_Nonnull attributionStateData =
        [attributionStateStorage readOnlyStoredDataValue];

    ADJAttributionData *_Nullable attributionData = attributionStateData.attributionData;

    if (attributionData != nil) {
        ADJAdjustAttribution *_Nonnull adjustAttribution = [attributionData toAdjustAttribution];

        [clientReturnExecutor executeClientReturnWithBlock:^{
            [adjustAttributionCallback didReadWithAdjustAttribution:adjustAttribution];
        }];
        return;
    }

    if ([attributionStateData unavailableStatus]) {
        [clientReturnExecutor executeClientReturnWithBlock:^{
            [adjustAttributionCallback unableToReadAdjustAttributionWithMessage:
             @"Cannot read attribution data because it is not available from the backend"];
        }];
    } else {
        [clientReturnExecutor executeClientReturnWithBlock:^{
            [adjustAttributionCallback unableToReadAdjustAttributionWithMessage:
             @"Cannot read attribution data because it still waiting."
             " Please try again later or subscribe for attribution at sdk init"];
        }];
    }
}

- (void)ccDeviceIdsWithCallback:(nonnull id<ADJAdjustDeviceIdsCallback>)adjustDeviceIdsCallback {
    id<ADJClientReturnExecutor> clientReturnExecutor = self.clientReturnExecutorWeak;
    if (clientReturnExecutor == nil) {
        [self.logger debugDev:
         @"Cannot return device ids in callback without a client return executor"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJDeviceController *_Nullable deviceController = self.deviceControllerWeak;
    if (deviceController == nil) {
        NSString *_Nonnull errorMessage =
            @"Cannot return device ids in callback without a reference to the controller";

        [self.logger debugDev:errorMessage issueType:ADJIssueWeakReference];
        [clientReturnExecutor executeClientReturnWithBlock:^{
            [adjustDeviceIdsCallback unableToReadAdjustDeviceIdsWithMessage:errorMessage];
        }];
        return;
    }

    ADJSessionDeviceIdsData *_Nonnull sessionDeviceIdsData =
        [deviceController getSessionDeviceIdsSync];

    if (sessionDeviceIdsData.failMessage != nil) {
        ADJInputLogMessageData *_Nonnull clientInputLog =
            [[ADJInputLogMessageData alloc]
             initWithMessage:@"Cannot get device ids for callback"
             level:ADJAdjustLogLevelInfo
             messageParams:
                    [[NSDictionary alloc] initWithObjectsAndKeys:
                     sessionDeviceIdsData.failMessage, @"reason", nil]];
        
        [self.logger logWithInput:clientInputLog];

        NSString *_Nonnull clientMessage =
            [ADJConsoleLogger clientFormatMessage:clientInputLog
                                     isPreSdkInit:NO];

        [clientReturnExecutor executeClientReturnWithBlock:^{
            [adjustDeviceIdsCallback unableToReadAdjustDeviceIdsWithMessage:clientMessage];
        }];
        return;
    }

    ADJAdjustDeviceIds *_Nonnull adjustDeviceIds = [sessionDeviceIdsData toAdjustDeviceIds];
    [clientReturnExecutor executeClientReturnWithBlock:^{
        [adjustDeviceIdsCallback didReadWithAdjustDeviceIds:adjustDeviceIds];
    }];
}

@end


