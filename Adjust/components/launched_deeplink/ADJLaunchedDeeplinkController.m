//
//  ADJLaunchedDeeplinkController.m
//  Adjust
//
//  Created by Aditi Agrawal on 08/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLaunchedDeeplinkController.h"
#import "ADJUtilSys.h"
#import "ADJClickPackageData.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJLaunchedDeeplinkClientActionHandlerId = @"LaunchedDeeplinkController";

@interface ADJLaunchedDeeplinkController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readonly, weak, nonatomic) ADJMainQueueController *mainQueueControllerWeak;
@property (nullable, readonly, weak, nonatomic) ADJLaunchedDeeplinkStateStorage *launchedDeeplinkStorageWeak;

@end

@implementation ADJLaunchedDeeplinkController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    launchedDeeplinkStateStorage:
        (nonnull ADJLaunchedDeeplinkStateStorage *)launchedDeeplinkStateStorage
    mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"LaunchedDeeplinkController"];
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _mainQueueControllerWeak = mainQueueController;
    _launchedDeeplinkStorageWeak = launchedDeeplinkStateStorage;

    return self;
}

#pragma mark Public API
- (void)ccTrackLaunchedDeeplinkWithClientData:(nonnull ADJClientLaunchedDeeplinkData *)clientLaunchedDeeplinkData {
    [self ccTrackLaunchedDeeplinkWithClientData:clientLaunchedDeeplinkData
                                   apiTimestamp:nil
                clientActionRemoveStorageAction:nil];
}

#pragma mark - ADJClientActionHandler
- (BOOL)ccCanHandlePreFirstSessionClientAction {
    return NO;
}

- (void)ccHandleClientActionWithIoInjectedData:(nonnull ADJIoData *)clientActionIoInjectedData
                                  apiTimestamp:(nonnull ADJTimestampMilli *)apiTimestamp
                           removeStorageAction:(nonnull ADJSQLiteStorageActionBase *)removeStorageAction {
    ADJClientLaunchedDeeplinkData *_Nullable clientLaunchedDeeplinkData =
    [ADJClientLaunchedDeeplinkData
     instanceFromClientActionInjectedIoDataWithData:clientActionIoInjectedData
     logger:self.logger];

    if (clientLaunchedDeeplinkData == nil) {
        [ADJUtilSys finalizeAtRuntime:removeStorageAction];
        return;
    }

    [self ccTrackLaunchedDeeplinkWithClientData:clientLaunchedDeeplinkData
                                   apiTimestamp:apiTimestamp
                clientActionRemoveStorageAction:removeStorageAction];
}

#pragma mark Internal Methods
- (void)ccTrackLaunchedDeeplinkWithClientData:(nonnull ADJClientLaunchedDeeplinkData *)clientLaunchedDeeplinkData
                                 apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
              clientActionRemoveStorageAction:(nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction {
    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger debugDev:
         @"Cannot Track Launched Deeplink without a reference to sdk package builder"
                    issueType:ADJIssueWeakReference];
        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJLaunchedDeeplinkStateStorage *_Nullable launchedDeeplinkStorage =
    self.launchedDeeplinkStorageWeak;

    if (launchedDeeplinkStorage == nil) {
        [self.logger debugDev:@"Cannot Track Deeplink without a reference to storage"
                    issueType:ADJIssueWeakReference];
        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger debugDev:
         @"Cannot Track Launched Deeplink without a reference to main queue controller"
                    issueType:ADJIssueWeakReference];
        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJClickPackageData *_Nonnull launchedDeeplinkClickPackageData =
    [sdkPackageBuilder buildLaunchedDeeplinkClickWithClientData:clientLaunchedDeeplinkData
                                                   apiTimestamp:apiTimestamp];

    [mainQueueController addClickPackageToSendWithData:launchedDeeplinkClickPackageData
                                   sqliteStorageAction:clientActionRemoveStorageAction];

    [launchedDeeplinkStorage updateWithNewDataValue:[[ADJLaunchedDeeplinkStateData alloc] initWithLaunchedDeeplink:clientLaunchedDeeplinkData.launchedDeeplink]];
}

@end

