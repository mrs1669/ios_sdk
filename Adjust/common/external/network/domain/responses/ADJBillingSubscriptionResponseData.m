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
+ (nonnull ADJOptionalFailsNN<ADJBillingSubscriptionResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    billingSubscriptionPackageData:
        (nonnull ADJBillingSubscriptionPackageData *)billingSubscriptionPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut = [[NSMutableArray alloc] init];
    return [[ADJOptionalFailsNN alloc]
            initWithOptionalFails:optionalFailsMut
            value:[[ADJBillingSubscriptionResponseData alloc]
                   initWithBuilder:sdkResponseDataBuilder
                   billingSubscriptionPackageData:billingSubscriptionPackageData
                   optionalFailsMut:optionalFailsMut]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    billingSubscriptionPackageData:
        (nonnull ADJBillingSubscriptionPackageData *)billingSubscriptionPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:billingSubscriptionPackageData
                 optionalFailsMut:optionalFailsMut];

    return self;
}

- (nonnull ADJBillingSubscriptionPackageData *)sourceBillingSubscriptionPackageData {
    return (ADJBillingSubscriptionPackageData *)self.sourcePackage;
}

@end
