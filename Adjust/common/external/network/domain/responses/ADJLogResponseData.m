//
//  ADJLogResponseData.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLogResponseData.h"

#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJLogPackageData *sourceLogPackageData;
 */

@implementation ADJLogResponseData
#pragma mark Instantiation
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJLogResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    logPackageData:(nonnull ADJLogPackageData *)logPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsBuilder = [[NSMutableArray alloc] init];
    return [[ADJCollectionAndValue alloc]
            initWithCollection:optionalFailsBuilder
            value:[[ADJLogResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               logPackageData:logPackageData
                                         optionalFailsBuilder:optionalFailsBuilder]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    logPackageData:(nonnull ADJLogPackageData *)logPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:logPackageData
             optionalFailsBuilder:optionalFailsBuilder];

    return self;
}

- (nonnull ADJLogPackageData *)sourceBillingSubscriptionPackageData {
    return (ADJLogPackageData *)self.sourcePackage;
}

@end
