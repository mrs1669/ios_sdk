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

@end

@implementation ADJThirdPartySharingController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController {
    self = [super initWithLoggerFactory:loggerFactory source:@"ThirdPartySharingController"];
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _mainQueueControllerWeak = mainQueueController;

    return self;
}

#pragma mark Public API
- (void)ccTrackThirdPartySharingWithClientData:(nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData {
    [self trackThirdPartySharingWithClientData:clientThirdPartySharingData
                                  apiTimestamp:nil
               clientActionRemoveStorageAction:nil];
}

#pragma mark - ADJClientActionHandler
- (BOOL)ccCanHandleClientActionWithIsPreFirstSession:(BOOL)isPreFirstSession {
    // can handle pre first session
    return YES;
}

- (void)ccHandleClientActionWithClientActionIoInjectedData:(nonnull ADJIoData *)clientActionIoInjectedData
                                              apiTimestamp:(nonnull ADJTimestampMilli *)apiTimestamp
                           clientActionRemoveStorageAction:(nonnull ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction {
    ADJClientThirdPartySharingData *_Nullable clientThirdPartySharingData =
    [ADJClientThirdPartySharingData
     instanceFromClientActionInjectedIoDataWithData:clientActionIoInjectedData
     logger:self.logger];

    if (clientThirdPartySharingData == nil) {
        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    [self trackThirdPartySharingWithClientData:clientThirdPartySharingData
                                  apiTimestamp:apiTimestamp
               clientActionRemoveStorageAction:clientActionRemoveStorageAction];
}

#pragma mark Internal Methods
- (void)trackThirdPartySharingWithClientData:(nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData
                                apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
             clientActionRemoveStorageAction:(nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction {
    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger error:@"Cannot Track Third Party Sharing"
         " without a reference to sdk package builder"];

        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger error:@"Cannot Track Third Party Sharing"
         " without a reference to main queue controller"];

        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJThirdPartySharingPackageData *_Nonnull thirdPartySharingPackageData =
    [sdkPackageBuilder buildThirdPartySharingWithClientData:clientThirdPartySharingData
                                               apiTimestamp:apiTimestamp];

    [mainQueueController
     addThirdPartySharingPackageToSendWithData:thirdPartySharingPackageData
     sqliteStorageAction:clientActionRemoveStorageAction];
}

@end
