//
//  ADJThirdPartySharingController.m
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJThirdPartySharingController.h"

#import "ADJUtilSys.h"
#import "ADJThirdPartySharingPackageData.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJThirdPartySharingControllerClientActionHandlerId = @"ThirdPartySharingController";

@interface ADJThirdPartySharingController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readonly, weak, nonatomic) ADJMainQueueController *mainQueueControllerWeak;

#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL isDeactivatedByCoppa;

@end

@implementation ADJThirdPartySharingController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"ThirdPartySharingController"];
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _mainQueueControllerWeak = mainQueueController;

    _isDeactivatedByCoppa = NO;

    return self;
}

#pragma mark Public API
- (void)
    ccTrackThirdPartySharingWithClientData:
        (nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData
    storageAction:(nullable ADJSQLiteStorageActionBase *)storageAction
{
    [self ccTrackThirdPartySharingWithClientData:clientThirdPartySharingData
                                    apiTimestamp:nil
                                   storageAction:storageAction];
}

- (void)ccDeactivateFromCoppa {
    self.isDeactivatedByCoppa = YES;
}

#pragma mark - ADJClientActionHandler
- (BOOL)ccCanHandlePreFirstSessionClientAction {
    return YES;
}

- (void)
    ccHandleClientActionWithIoInjectedData:(nonnull ADJIoData *)clientActionIoInjectedData
    apiTimestamp:(nonnull ADJTimestampMilli *)apiTimestamp
    removeStorageAction:(nonnull ADJSQLiteStorageActionBase *)removeStorageAction
{
    ADJClientThirdPartySharingData *_Nullable clientThirdPartySharingData =
        [ADJClientThirdPartySharingData
         instanceFromClientActionInjectedIoDataWithData:clientActionIoInjectedData
         logger:self.logger];

    if (clientThirdPartySharingData == nil) {
        [ADJUtilSys finalizeAtRuntime:removeStorageAction];
        return;
    }

    [self ccTrackThirdPartySharingWithClientData:clientThirdPartySharingData
                                    apiTimestamp:apiTimestamp
                                   storageAction:removeStorageAction];
}

#pragma mark Internal Methods
- (void)
    ccTrackThirdPartySharingWithClientData:
        (nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData
    apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
    storageAction:(nullable ADJSQLiteStorageActionBase *)storageAction
{
    if (self.isDeactivatedByCoppa) {
        [self.logger noticeClient:
         @"Cannot track third party sharing when it was disabled by Coppa"];

        [ADJUtilSys finalizeAtRuntime:storageAction];
        return;
    }

    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger debugDev:
         @"Cannot Track Third Party Sharing without a reference to sdk package builder"
                    issueType:ADJIssueWeakReference];

        [ADJUtilSys finalizeAtRuntime:storageAction];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger debugDev:
         @"Cannot Track Third Party Sharing without a reference to main queue controller"
                    issueType:ADJIssueWeakReference];

        [ADJUtilSys finalizeAtRuntime:storageAction];
        return;
    }

    ADJThirdPartySharingPackageData *_Nonnull thirdPartySharingPackageData =
        [sdkPackageBuilder buildThirdPartySharingWithClientData:clientThirdPartySharingData
                                                   apiTimestamp:apiTimestamp];

    [mainQueueController
     addThirdPartySharingPackageToSendWithData:thirdPartySharingPackageData
     sqliteStorageAction:storageAction];
}

@end
