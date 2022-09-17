//
//  ADJBillingSubscriptionResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseBaseData.h"
#import "ADJBillingSubscriptionPackageData.h"

@interface ADJBillingSubscriptionResponseData : ADJSdkResponseBaseData
// instantiation
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
         billingSubscriptionPackageData:(nonnull ADJBillingSubscriptionPackageData *)billingSubscriptionPackageData
                                 logger:(nonnull ADJLogger *)logger;

// public properties
@property (nonnull, readonly, strong, nonatomic)ADJBillingSubscriptionPackageData *sourceBillingSubscriptionPackageData;

@end
