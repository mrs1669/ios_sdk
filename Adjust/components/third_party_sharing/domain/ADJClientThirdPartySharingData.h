//
//  ADJClientThirdPartySharingData.h
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientActionIoDataInjectable.h"
#import "ADJAdjustThirdPartySharing.h"
#import "ADJIoData.h"
#import "ADJLogger.h"
#import "ADJBooleanWrapper.h"
#import "ADJNonEmptyString.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJClientThirdPartySharingDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJClientThirdPartySharingData : NSObject<ADJClientActionIoDataInjectable>
// instantiation
+ (nullable instancetype)instanceFromClientWithAdjustThirdPartySharing:(nullable ADJAdjustThirdPartySharing *)adjustThirdPartySharing
                                                                logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJBooleanWrapper *enabledOrElseDisabledSharing;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *stringGranularOptionsByName;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *stringPartnerSharingSettingsByName;


@end
