//
//  ADJLogResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseBaseData.h"
#import "ADJLogPackageData.h"

@interface ADJLogResponseData : ADJSdkResponseBaseData
// instantiation
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                         logPackageData:(nonnull ADJLogPackageData *)logPackageData
                                 logger:(nonnull ADJLogger *)logger;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJLogPackageData *sourceLogPackageData;

@end
