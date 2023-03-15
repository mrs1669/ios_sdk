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
+ (nonnull ADJOptionalFailsNN<ADJLogResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    logPackageData:(nonnull ADJLogPackageData *)logPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut = [[NSMutableArray alloc] init];
    return [[ADJOptionalFailsNN alloc]
            initWithOptionalFails:optionalFailsMut
            value:[[ADJLogResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               logPackageData:logPackageData
                                             optionalFailsMut:optionalFailsMut]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    logPackageData:(nonnull ADJLogPackageData *)logPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:logPackageData
                 optionalFailsMut:optionalFailsMut];

    return self;
}

- (nonnull ADJLogPackageData *)sourceBillingSubscriptionPackageData {
    return (ADJLogPackageData *)self.sourcePackage;
}

@end
