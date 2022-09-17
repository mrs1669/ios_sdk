//
//  ADJBillingSubscriptionController.m
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//
#import "ADJBillingSubscriptionController.h"

#import "ADJUtilSys.h"
#import "ADJBillingSubscriptionPackageData.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJBillingSubscriptionControllerClientActionHandlerId =
@"BillingSubscriptionController";

@interface ADJBillingSubscriptionController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readonly, weak, nonatomic)
ADJMainQueueController *mainQueueControllerWeak;

@end

@implementation ADJBillingSubscriptionController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController {
    self = [super initWithLoggerFactory:loggerFactory source:@"BillingSubscriptionController"];
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _mainQueueControllerWeak = mainQueueController;

    return self;
}

#pragma mark Public API
- (void)ccTrackBillingSubscriptionWithClientData:(nonnull ADJClientBillingSubscriptionData *)clientBillingSubscriptionData {
    [self trackBillingSubscriptionWithClientData:clientBillingSubscriptionData
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
    ADJClientBillingSubscriptionData *_Nullable clientBillingSubscriptionData =
    [ADJClientBillingSubscriptionData
     instanceFromClientActionInjectedIoDataWithData:clientActionIoInjectedData
     logger:self.logger];

    if (clientBillingSubscriptionData == nil) {
        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    [self trackBillingSubscriptionWithClientData:clientBillingSubscriptionData
                                    apiTimestamp:apiTimestamp
                 clientActionRemoveStorageAction:clientActionRemoveStorageAction];
}

#pragma mark Internal Methods
- (void)trackBillingSubscriptionWithClientData:(nonnull ADJClientBillingSubscriptionData *)clientBillingSubscriptionData
                                  apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
               clientActionRemoveStorageAction:(nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction {
    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger error:@"Cannot Track Billing Subscription"
         " without a reference to sdk package builder"];

        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger error:@"Cannot Track Billing Subscription"
         " without a reference to main queue controller"];

        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJBillingSubscriptionPackageData *_Nonnull billingSubscriptionPackageData =
    [sdkPackageBuilder buildBillingSubscriptionWithClientData:clientBillingSubscriptionData
                                                 apiTimestamp:apiTimestamp];

    [mainQueueController
     addBillingSubscriptionPackageToSendWithData:billingSubscriptionPackageData
     sqliteStorageAction:clientActionRemoveStorageAction];
}

@end

