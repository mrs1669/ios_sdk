//
//  ADJPushTokenController.m
//  Adjust
//
//  Created by Aditi Agrawal on 30/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJPushTokenController.h"

#import "ADJUtilSys.h"
#import "ADJInfoPackageData.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJPushTokenControllerClientActionHandlerId = @"PushTokenController";

@interface ADJPushTokenController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJPushTokenStateStorage *pushTokenStorageWeak;
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readonly, weak, nonatomic) ADJMainQueueController *mainQueueControllerWeak;

@end

@implementation ADJPushTokenController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                        pushTokenStateStorage:(nonnull ADJPushTokenStateStorage *)pushTokenStateStorage
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController {
    self = [super initWithLoggerFactory:loggerFactory source:@"PushTokenController"];
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _pushTokenStorageWeak = pushTokenStateStorage;
    _mainQueueControllerWeak = mainQueueController;

    return self;
}

#pragma mark Public API
- (void)ccTrackPushTokenWithClientData:(nonnull ADJClientPushTokenData *)clientPushTokenData {
    [self trackPushTokenWithClientData:clientPushTokenData
                          apiTimestamp:nil
       clientActionRemoveStorageAction:nil];
}

#pragma mark - ADJClientActionHandler
- (BOOL)ccCanHandleClientActionWithIsPreFirstSession:(BOOL)isPreFirstSession {
    // cannot handle pre first session
    return !isPreFirstSession;
}

- (void)ccHandleClientActionWithClientActionIoInjectedData:(nonnull ADJIoData *)clientActionIoInjectedData
                                              apiTimestamp:(nonnull ADJTimestampMilli *)apiTimestamp
                           clientActionRemoveStorageAction:(nonnull ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction {
    ADJClientPushTokenData *_Nullable clientPushTokenData = [ADJClientPushTokenData
                                                             instanceFromClientActionInjectedIoDataWithData:clientActionIoInjectedData
                                                             logger:self.logger];

    if (clientPushTokenData == nil) {
        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    [self trackPushTokenWithClientData:clientPushTokenData
                          apiTimestamp:apiTimestamp
       clientActionRemoveStorageAction:clientActionRemoveStorageAction];
}

#pragma mark Internal Methods
- (void)trackPushTokenWithClientData:(nonnull ADJClientPushTokenData *)clientPushTokenData
                        apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
     clientActionRemoveStorageAction:(nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction {

    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger debugDev:@"Cannot Track Push Token without a reference to sdk package builder"
                    issueType:ADJIssueWeakReference];
        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJPushTokenStateStorage *_Nullable pushTokenStorage = self.pushTokenStorageWeak;
    if (pushTokenStorage == nil) {
        [self.logger debugDev:@"Cannot Track Push Token without a reference to storage"
                    issueType:ADJIssueWeakReference];
        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger debugDev:@"Cannot Track Push Token without a reference to main queue controller"
                    issueType:ADJIssueWeakReference];
        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJPushTokenStateData *_Nullable pushTokenStateData = pushTokenStorage.readOnlyStoredDataValue;

    if (clientPushTokenData != nil && pushTokenStateData != nil) {
        if ([clientPushTokenData.pushTokenString isEqual:pushTokenStateData.cachedPushTokenString]) {
            [self.logger debugDev:@"Cannot Track Push Token, already tracked"];
            [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
            return;
        }
    }

    ADJInfoPackageData *_Nonnull infoPackageData = [sdkPackageBuilder buildInfoPackageWithClientData:clientPushTokenData
                                                                                        apiTimestamp:apiTimestamp];

    [mainQueueController addInfoPackageToSendWithData:infoPackageData
                                  sqliteStorageAction:clientActionRemoveStorageAction];

    [pushTokenStorage updateWithNewDataValue:[[ADJPushTokenStateData alloc]
                                              initWithPushTokenString:clientPushTokenData.pushTokenString]];

}

@end

