//
//  ADJMeasurementConsentController.h
//  Adjust
//
//  Created by Genady Buchatsky on 16.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJCommonBase.h"
#import "ADJClientActionHandler.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJMainQueueController.h"
#import "ADJClientMeasurementConsentData.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJMeasurementConsentControllerClientActionHandlerId;

NS_ASSUME_NONNULL_END

@interface ADJMeasurementConsentController : ADJCommonBase <ADJClientActionHandler>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController;
// public api
- (void)ccTrackMeasurementConsent:(nonnull ADJClientMeasurementConsentData *)consentData;
@end
