//
//  ADJClientMeasurementConsentData.h
//  Adjust
//
//  Created by Genady Buchatsky on 10.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJClientActionIoDataInjectable.h"
#import "ADJBooleanWrapper.h"
#import "ADJLogger.h"
#import "ADJIoData.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJClientMeasurementConsentDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJClientMeasurementConsentData : NSObject<ADJClientActionIoDataInjectable>
// public properties
@property (nonnull, readonly, strong, nonatomic) ADJBooleanWrapper *measurementConsentWasActivated;

// instantiation
+ (nullable instancetype)instanceWithActivateConsent;

+ (nullable instancetype)instanceWithInactivateConsent;

// TODO: GENA - Rename all these functions
// instanceFromClientActionIoData:(nonnull ADJIoData *)clientActionIoData
+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger;
- (nullable instancetype)init NS_UNAVAILABLE;
@end

