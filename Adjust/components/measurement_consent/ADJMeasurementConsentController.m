//
//  ADJMeasurementConsentController.m
//  Adjust
//
//  Created by Genady Buchatsky on 16.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJMeasurementConsentController.h"
#import "ADJMeasurementConsentPackageData.h"
#import "ADJUtilSys.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJMeasurementConsentControllerClientActionHandlerId = @"MeasurementConsentController";

@interface ADJMeasurementConsentController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readonly, weak, nonatomic) ADJMainQueueController *mainQueueControllerWeak;
@end

#pragma mark Instantiation
@implementation ADJMeasurementConsentController

- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController {

    self = [super initWithLoggerFactory:loggerFactory source:@"MeasurementConsentController"];
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _mainQueueControllerWeak = mainQueueController;

    return self;
}

#pragma mark Public API
- (void)ccTrackMeasurementConsent:(nonnull ADJClientMeasurementConsentData *)consentData {
    [self ccTrackMeasurementConsent:consentData
                       apiTimestamp:nil
    clientActionRemoveStorageAction:nil];
}

#pragma mark - ADJClientActionHandler
- (BOOL)ccCanHandlePreFirstSessionClientAction {
    return YES;
}

- (void)ccHandleClientActionWithIoInjectedData:(nonnull ADJIoData *)clientActionIoInjectedData
                                  apiTimestamp:(nonnull ADJTimestampMilli *)apiTimestamp
                           removeStorageAction:(nonnull ADJSQLiteStorageActionBase *)removeStorageAction {

    ADJClientMeasurementConsentData *_Nullable consentData =
    [ADJClientMeasurementConsentData instanceFromClientActionInjectedIoDataWithData:clientActionIoInjectedData
                                                                             logger:self.logger];

    if (consentData == nil) {
        [ADJUtilSys finalizeAtRuntime:removeStorageAction];
        return;
    }

    [self ccTrackMeasurementConsent:consentData
                       apiTimestamp:apiTimestamp
    clientActionRemoveStorageAction:removeStorageAction];
}

#pragma mark Internal Methods
- (void)ccTrackMeasurementConsent:(nonnull ADJClientMeasurementConsentData *)consentData
                     apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
  clientActionRemoveStorageAction:(nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction {

    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger debugDev:@"Cannot Track Measurement Consent without a reference to sdk package builder"
                    issueType:ADJIssueWeakReference];

        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger debugDev:
         @"Cannot Track Push Token without a reference to main queue controller"
                    issueType:ADJIssueWeakReference];

        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJMeasurementConsentPackageData *_Nonnull measurementConsentPackageData =
    [sdkPackageBuilder buildMeasurementConsentPackageWithClientData:consentData
                                                       apiTimestamp:apiTimestamp];

    [mainQueueController addMeasurementConsentPackageToSendWithData:measurementConsentPackageData
                                                sqliteStorageAction:clientActionRemoveStorageAction];
}
@end
