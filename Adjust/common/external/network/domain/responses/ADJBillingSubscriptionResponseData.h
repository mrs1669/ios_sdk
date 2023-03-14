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
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJBillingSubscriptionResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    billingSubscriptionPackageData:
        (nonnull ADJBillingSubscriptionPackageData *)billingSubscriptionPackageData;

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
 NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic)
    ADJBillingSubscriptionPackageData *sourceBillingSubscriptionPackageData;

@end
