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
@property (nullable, readonly, weak, nonatomic)
    ADJThirdPartySharingController *tpsControllerWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJCoppaState *state;

@end

@implementation ADJCoppaController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    thirdPartySharingController:
        (nonnull ADJThirdPartySharingController *)thirdPartySharingController
    coppaStateStorage:(nonnull ADJCoppaStateStorage *)coppaStateStorage
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"CoppaController"];
    _storage = coppaStateStorage;
    _tpsControllerWeak = thirdPartySharingController;

    _state = [[ADJCoppaState alloc]
              initWithLoggerFactory:loggerFactory
              initialStateData:[coppaStateStorage readOnlyStoredDataValue]];

    return self;
}

#pragma mark Public API
#pragma mark - ADJSdkInitSubscriber
- (void)ccOnSdkInitWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData {
    ADJThirdPartySharingController *_Nullable tpsController = self.tpsControllerWeak;
    if (tpsController == nil) {
        [self.logger debugDev:@"Cannot handle sdk init without a reference to tps controller"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJCoppaStateOutputData *_Nullable outputStateData =
        [self.state sdkInitWithWasCoppaEnabledByClient:clientConfigData.isCoppaEnabled];

    if (outputStateData == nil) {
        return;
    }

    ADJSQLiteStorageActionBase *_Nullable updatedStateDataStorageAction =
        [self ccSaveChangedStateData:outputStateData.changedStateData];

    if (outputStateData.trackTPSbeforeDeactivate) {
        // track tps disable sharing as if it comes from the client
        //  could be done with a dedicated api, but it would not be a difference at the moment
        [tpsController
         ccTrackThirdPartySharingWithClientData:
             [ADJClientThirdPartySharingData instanceFromCoppaToDisable]
         storageAction:updatedStateDataStorageAction];
    } else {
        [ADJUtilSys finalizeAtRuntime:updatedStateDataStorageAction];
    }

    if (outputStateData.deactivateTPSafterTracking) {
        [tpsController ccDeactivateFromCoppa];
    }
}

#pragma mark Internal Methods
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
