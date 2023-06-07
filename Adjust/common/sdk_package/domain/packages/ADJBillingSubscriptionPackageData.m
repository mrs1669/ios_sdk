//
//  ADJBillingSubscriptionPackageData.m
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJBillingSubscriptionPackageData.h"

#import "ADJConstantsParam.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJBillingSubscriptionPackageDataPath = @"v2/purchase";

@implementation ADJBillingSubscriptionPackageData
#pragma mark Instantiation
- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters {
    self = [super initWithPath:ADJBillingSubscriptionPackageDataPath
                     clientSdk:clientSdk
  isPostOrElseGetNetworkMethod:YES
                    parameters:parameters];

    return self;
}

- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters
                                   ioData:(nonnull ADJIoData *)ioData
{
    // does not read ioData for further information
    return [self initWithClientSdk:clientSdk parameters:parameters];
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSdkPackageBaseData
- (nonnull ADJNonEmptyString *)concreteGenerateShortDescription {
    ADJNonEmptyString *_Nullable billingStoreValue =
    [self.parameters pairValueWithKey:ADJParamSubscriptionBillingStoreKey];

    if (billingStoreValue != nil) {
        return [[ADJNonEmptyString alloc]
                initWithConstStringValue:
                    [NSString stringWithFormat:
                     @"Billing Subscription from billing store: %@", billingStoreValue]];
    }

    return [[ADJNonEmptyString alloc] initWithConstStringValue:
            @"Billing Subscription without from billing store"];
}

@end
