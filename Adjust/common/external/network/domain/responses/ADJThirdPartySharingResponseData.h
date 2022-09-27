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
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
           thirdPartySharingPackageData:(nonnull ADJThirdPartySharingPackageData *)thirdPartySharingPackageData
                                 logger:(nonnull ADJLogger *)logger;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJThirdPartySharingPackageData *sourceThirdPartySharingPackageData;

@end
