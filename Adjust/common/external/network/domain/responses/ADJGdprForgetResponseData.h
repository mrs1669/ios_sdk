//
//  ADJGdprForgetResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkResponseBaseData.h"
#import "ADJGdprForgetPackageData.h"

@interface ADJGdprForgetResponseData : ADJSdkResponseBaseData
// instantiation
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                  gdprForgetPackageData:(nonnull ADJGdprForgetPackageData *)gdprForgetPackageData
                                 logger:(nonnull ADJLogger *)logger;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJGdprForgetPackageData *sourceGdprForgetPackage;

@end
