//
//  ADJCoppaController.m
//  Adjust
//
//  Created by Pedro Silva on 28.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJCoppaController.h"

#import "ADJCoppaState.h"
#import "ADJUtilSys.h"

@interface ADJCoppaController ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJCoppaStateStorage *storage;
@property (nullable, readonly, weak, nonatomic) ADJThirdPartySharingController *tpsControllerWeak;
@property (nullable, readonly, weak, nonatomic) ADJDeviceController *deviceControllerWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJCoppaState *state;

@end

@implementation ADJCoppaController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    thirdPartySharingController:
        (nonnull ADJThirdPartySharingController *)thirdPartySharingController
    deviceController:(nonnull ADJDeviceController *)deviceController
    coppaStateStorage:(nonnull ADJCoppaStateStorage *)coppaStateStorage
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"CoppaController"];
    _storage = coppaStateStorage;
    _tpsControllerWeak = thirdPartySharingController;
    _deviceControllerWeak = deviceController;

    _state = [[ADJCoppaState alloc]
              initWithLoggerFactory:loggerFactory
              initialStateData:[coppaStateStorage readOnlyStoredDataValue]];

    return self;
}

#pragma mark Public API
#pragma mark - ADJSdkInitSubscriber
- (void)ccOnSdkInitWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData {
    ADJCoppaStateOutputData *_Nullable outputData =
        [self.state sdkInitWithWasCoppaEnabledByClient:clientConfigData.isCoppaEnabled];

    if (outputData == nil) {
        return;
    }

    // Device ids should be handled before, since it needs to prevent them from being read
    // At the moment, there is no other sdkInit subscriber that can create a new package that
    //  would read device ids.
    // The sdk start that can create a new session package subscribes to postSdkInit, that is
    //  guaranteed to be called *after* sdkInit
    // If at any point, some other package can be created in another sdkInit subscriber, then
    //  this should be changed to guarantee that the device ids are prevented from being read
    //  when coppa is enabled
    [self ccHandleDeviceIdsWithOutputData:outputData];

    [self ccHandleTPSWithOutputData:outputData];
}

#pragma mark Internal Methods
- (void)ccHandleDeviceIdsWithOutputData:(nonnull ADJCoppaStateOutputData *)outputData {
    if (! outputData.deactivateDeviceIds) {
        return;
    }

    ADJDeviceController *_Nullable deviceController = self.deviceControllerWeak;
    if (deviceController == nil) {
        [self.logger debugDev:
         @"Cannot handle device ids changes without a reference to device controller"
                    issueType:ADJIssueWeakReference];
        return;
    }

    [deviceController ccDeactivateDeviceIdsForCoppa];
}

- (void)ccHandleTPSWithOutputData:
    (nonnull ADJCoppaStateOutputData *)outputData
{
    ADJSQLiteStorageActionBase *_Nullable updatedStateDataStorageAction =
        [self ccSaveChangedStateData:outputData.changedStateData];

    ADJThirdPartySharingController *_Nullable tpsController = self.tpsControllerWeak;
    if (tpsController == nil) {
        [self.logger debugDev:@"Cannot handle tps changes without a reference to tps controller"
                    issueType:ADJIssueWeakReference];
        [ADJUtilSys finalizeAtRuntime:updatedStateDataStorageAction];
        return;
    }

    if (outputData.trackTPSbeforeDeactivate) {
        // track tps disable sharing as if it comes from the client
        //  could be done with a dedicated api, but it would not be a difference at the moment
        [tpsController
         ccTrackThirdPartySharingWithClientData:
             [ADJClientThirdPartySharingData instanceFromCoppaToDisable]
         storageAction:updatedStateDataStorageAction];
    } else {
        [ADJUtilSys finalizeAtRuntime:updatedStateDataStorageAction];
    }

    if (outputData.deactivateTPSafterTracking) {
        [tpsController ccDeactivateFromCoppa];
    }
}

- (nullable ADJSQLiteStorageActionBase *)
    ccSaveChangedStateData:(nullable ADJCoppaStateData *)changedStateData
{
    if (changedStateData == nil) {
        return nil;
    }

    return [[ADJCoppaStateStorageAction alloc] initWithCoppaStateStorage:self.storage
                                                          coppaStateData:changedStateData];
}

@end
