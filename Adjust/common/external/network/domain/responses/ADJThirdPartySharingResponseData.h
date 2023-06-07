//
//  ADJThirdPartySharingResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseBaseData.h"
#import "ADJThirdPartySharingPackageData.h"

@interface ADJThirdPartySharingResponseData : ADJSdkResponseBaseData
// instantiation
+ (nonnull ADJOptionalFailsNN<ADJThirdPartySharingResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    thirdPartySharingPackageData:
        (nonnull ADJThirdPartySharingPackageData *)thirdPartySharingPackageData;

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
 NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJThirdPartySharingPackageData *sourceThirdPartySharingPackageData;

@end
