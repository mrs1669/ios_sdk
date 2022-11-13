//
//  ADJAdRevenueController.m
//  Adjust
//
//  Created by Aditi Agrawal on 23/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdRevenueController.h"

#import "ADJUtilSys.h"
#import "ADJAdRevenuePackageData.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJAdRevenueControllerClientActionHandlerId = @"AdRevenueController";

@interface ADJAdRevenueController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readonly, weak, nonatomic) ADJMainQueueController *mainQueueControllerWeak;

@end

@implementation ADJAdRevenueController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController {
    self = [super initWithLoggerFactory:loggerFactory source:@"AdRevenueController"];
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _mainQueueControllerWeak = mainQueueController;

    return self;
}

#pragma mark Public API
- (void)ccTrackAdRevenueWithClientData:(nonnull ADJClientAdRevenueData *)clientAdRevenueData {
    [self trackAdRevenueWithClientData:clientAdRevenueData
                          apiTimestamp:nil
       clientActionRemoveStorageAction:nil];
}

#pragma mark - ADJClientActionHandler
- (BOOL)ccCanHandleClientActionWithIsPreFirstSession:(BOOL)isPreFirstSession {
    // cannot handle pre first session
    return ! isPreFirstSession;
}

- (void)ccHandleClientActionWithClientActionIoInjectedData:(nonnull ADJIoData *)clientActionIoInjectedData
                                              apiTimestamp:(nonnull ADJTimestampMilli *)apiTimestamp
                           clientActionRemoveStorageAction:(nonnull ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction {
    ADJClientAdRevenueData *_Nullable clientAdRevenueData = [ADJClientAdRevenueData
                                                             instanceFromClientActionInjectedIoDataWithData:clientActionIoInjectedData
                                                             logger:self.logger];

    if (clientAdRevenueData == nil) {
        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    [self trackAdRevenueWithClientData:clientAdRevenueData
                          apiTimestamp:apiTimestamp
       clientActionRemoveStorageAction:clientActionRemoveStorageAction];
}

#pragma mark Internal Methods
- (void)
    trackAdRevenueWithClientData:(nonnull ADJClientAdRevenueData *)clientAdRevenueData
    apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
    clientActionRemoveStorageAction:
        (nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction
{
    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger debugDev:
            @"Cannot Track Ad Revenue without a reference to sdk package builder"
                    issueType:ADJIssueWeakReference];

        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger debugDev:
            @"Cannot Track Ad Revenue without a reference to main queue controller"
                    issueType:ADJIssueWeakReference];

        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJAdRevenuePackageData *_Nonnull adRevenuePackageData =
    [sdkPackageBuilder buildAdRevenueWithClientData:clientAdRevenueData
                                       apiTimestamp:apiTimestamp];

    [mainQueueController addAdRevenuePackageToSendWithData:adRevenuePackageData
                                       sqliteStorageAction:clientActionRemoveStorageAction];
}

@end



