//
//  ADJClickResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseBaseData.h"
#import "ADJClickPackageData.h"

@interface ADJClickResponseData : ADJSdkResponseBaseData
// instantiation
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJClickResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    clickPackageData:(nonnull ADJClickPackageData *)clickPackageData;

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
 NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJClickPackageData *sourceClickPackageData;

@end
