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
NSString *const ADJBillingSubscriptionControllerClientActionHandlerId = @"BillingSubscriptionController";

@interface ADJBillingSubscriptionController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readonly, weak, nonatomic) ADJMainQueueController *mainQueueControllerWeak;

@end

@implementation ADJBillingSubscriptionController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"BillingSubscriptionController"];
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
- (BOOL)ccCanHandlePreFirstSessionClientAction {
    return NO;
}

- (void)ccHandleClientActionWithIoInjectedData:(nonnull ADJIoData *)clientActionIoInjectedData
                                  apiTimestamp:(nonnull ADJTimestampMilli *)apiTimestamp
                           removeStorageAction:(nonnull ADJSQLiteStorageActionBase *)removeStorageAction {
    ADJClientBillingSubscriptionData *_Nullable clientBillingSubscriptionData =
    [ADJClientBillingSubscriptionData
     instanceFromClientActionInjectedIoDataWithData:clientActionIoInjectedData
     logger:self.logger];

    if (clientBillingSubscriptionData == nil) {
        [ADJUtilSys finalizeAtRuntime:removeStorageAction];
        return;
    }

    [self trackBillingSubscriptionWithClientData:clientBillingSubscriptionData
                                    apiTimestamp:apiTimestamp
                 clientActionRemoveStorageAction:removeStorageAction];
}

#pragma mark Internal Methods
- (void)trackBillingSubscriptionWithClientData:(nonnull ADJClientBillingSubscriptionData *)clientBillingSubscriptionData
                                  apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
               clientActionRemoveStorageAction:(nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction {
    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger debugDev:
         @"Cannot Track Billing Subscription without a reference to sdk package builder"
                    issueType:ADJIssueWeakReference];

        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger debugDev:
         @"Cannot Track Billing Subscription without a reference to main queue controller"
                    issueType:ADJIssueWeakReference];

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

