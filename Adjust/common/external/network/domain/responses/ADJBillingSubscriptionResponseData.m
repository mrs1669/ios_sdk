//
//  ADJBillingSubscriptionResponseData.m
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJBillingSubscriptionResponseData.h"

@implementation ADJBillingSubscriptionResponseData
#pragma mark Instantiation
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
         billingSubscriptionPackageData:(nonnull ADJBillingSubscriptionPackageData *)billingSubscriptionPackageData
                                 logger:(nonnull ADJLogger *)logger {

    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:billingSubscriptionPackageData
                           logger:logger];

    return self;
}

- (nonnull ADJBillingSubscriptionPackageData *)sourceBillingSubscriptionPackageData {
    return (ADJBillingSubscriptionPackageData *)self.sourcePackage;
}

@end
