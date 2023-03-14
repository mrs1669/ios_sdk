//
//  ADJInfoResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 30/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseBaseData.h"
#import "ADJInfoPackageData.h"

@interface ADJInfoResponseData : ADJSdkResponseBaseData
// instantiation
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJInfoResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    infoPackageData:(nonnull ADJInfoPackageData *)infoPackageData;

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
 NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJInfoPackageData *infoPackageData;

@end
