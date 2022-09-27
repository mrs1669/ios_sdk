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
- (nonnull instancetype) initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                          logPackageData:(nonnull ADJLogPackageData *)logPackageData
                                  logger:(nonnull ADJLogger *)logger {
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:logPackageData
                           logger:logger];

    return self;
}

- (nonnull ADJLogPackageData *)sourceBillingSubscriptionPackageData {
    return (ADJLogPackageData *)self.sourcePackage;
}

@end
