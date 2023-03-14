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
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJBillingSubscriptionResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    billingSubscriptionPackageData:
        (nonnull ADJBillingSubscriptionPackageData *)billingSubscriptionPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsBuilder = [[NSMutableArray alloc] init];
    return [[ADJCollectionAndValue alloc]
            initWithCollection:optionalFailsBuilder
            value:[[ADJBillingSubscriptionResponseData alloc]
                   initWithBuilder:sdkResponseDataBuilder
                   billingSubscriptionPackageData:billingSubscriptionPackageData
                   optionalFailsBuilder:optionalFailsBuilder]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    billingSubscriptionPackageData:
        (nonnull ADJBillingSubscriptionPackageData *)billingSubscriptionPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:billingSubscriptionPackageData
             optionalFailsBuilder:optionalFailsBuilder];

    return self;
}

- (nonnull ADJBillingSubscriptionPackageData *)sourceBillingSubscriptionPackageData {
    return (ADJBillingSubscriptionPackageData *)self.sourcePackage;
}

@end
