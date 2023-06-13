//
//  ADJSdkResponseDataBuilder.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkResponseDataBuilder.h"

#import "ADJUtilF.h"
#import "ADJAttributionPackageData.h"
#import "ADJAttributionResponseData.h"
#import "ADJBillingSubscriptionPackageData.h"
#import "ADJBillingSubscriptionResponseData.h"
#import "ADJClickPackageData.h"
#import "ADJClickResponseData.h"
#import "ADJGdprForgetPackageData.h"
#import "ADJGdprForgetResponseData.h"
#import "ADJLogPackageData.h"
#import "ADJLogResponseData.h"
#import "ADJSessionPackageData.h"
#import "ADJSessionResponseData.h"
#import "ADJEventPackageData.h"
#import "ADJEventResponseData.h"
#import "ADJAdRevenuePackageData.h"
#import "ADJAdRevenueResponseData.h"
#import "ADJInfoResponseData.h"
#import "ADJInfoPackageData.h"
#import "ADJThirdPartySharingPackageData.h"
#import "ADJThirdPartySharingResponseData.h"
#import "ADJMeasurementConsentPackageData.h"
#import "ADJMeasurementConsentResponseData.h"
#import "ADJUnknownResponseData.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) id<ADJSdkPackageData> sourcePackage;
 @property (nonnull, readonly, strong, nonatomic) ADJStringMapBuilder *sendingParameters;
 @property (nonnull, readonly, strong, nonatomic) id<ADJSdkResponseCallbackSubscriber> sourceCallback;
 @property (nullable, readwrite, strong, nonatomic) NSDictionary *jsonDictionary;
 */

@interface ADJSdkResponseDataBuilder ()
#pragma mark - Injected dependencies

#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) NSUInteger retries;

@end

@implementation ADJSdkResponseDataBuilder
#pragma mark Instantiation
- (nonnull instancetype)initWithSourceSdkPackage:(nonnull id<ADJSdkPackageData>)sourcePackage
                               sendingParameters:(nonnull ADJStringMapBuilder *)sendingParameters
                                  sourceCallback:(nonnull id<ADJSdkResponseCallbackSubscriber>)sourceCallback {
    self = [super init];
    _sourcePackage = sourcePackage;
    _sendingParameters = sendingParameters;
    _sourceCallback = sourceCallback;
    _jsonDictionary = nil;

    return self;
}

#pragma mark Public API
- (BOOL)didReceiveJsonResponse {
    return self.jsonDictionary != nil;
}

- (void)incrementRetries {
    self.retries = self.retries + 1;
}

#define tryBuildResponse(packageClassType, responseClassType, packageDataName)              \
    if ([self.sourcePackage isKindOfClass:[packageClassType class]]) {                      \
        return (ADJOptionalFails<id<ADJSdkResponseData>> *)                                 \
            [responseClassType instanceWithBuilder:self                                     \
                                   packageDataName:(packageClassType *)self.sourcePackage]; \
    }                                                                                       \

- (nonnull ADJOptionalFails<id<ADJSdkResponseData>> *)buildSdkResponseData {
    tryBuildResponse(ADJGdprForgetPackageData, ADJGdprForgetResponseData, gdprForgetPackageData)
    tryBuildResponse(ADJLogPackageData, ADJLogResponseData, logPackageData)
    tryBuildResponse(ADJClickPackageData, ADJClickResponseData, clickPackageData)
    tryBuildResponse(ADJBillingSubscriptionPackageData, ADJBillingSubscriptionResponseData, billingSubscriptionPackageData)
    tryBuildResponse(ADJAttributionPackageData, ADJAttributionResponseData, attributionPackageData)
    tryBuildResponse(ADJSessionPackageData, ADJSessionResponseData, sessionPackageData)
    tryBuildResponse(ADJEventPackageData, ADJEventResponseData, eventPackageData)
    tryBuildResponse(ADJAdRevenuePackageData, ADJAdRevenueResponseData, adRevenuePackageData)
    tryBuildResponse(ADJInfoPackageData, ADJInfoResponseData, infoPackageData)
    tryBuildResponse(ADJThirdPartySharingPackageData, ADJThirdPartySharingResponseData, thirdPartySharingPackageData)
    tryBuildResponse(ADJMeasurementConsentPackageData, ADJMeasurementConsentResponseData, measurementConsentPackageData)

    ADJResultFailBuilder *_Nonnull resultFailBuilder =
        [[ADJResultFailBuilder alloc] initWithMessage:
         @"Cannot not map source package into known type"];
    [resultFailBuilder withKey:@"source package short description"
                     stringValue:[self.sourcePackage generateShortDescription].stringValue];
    [resultFailBuilder withKey:@"source package class"
                   stringValue:NSStringFromClass([self.sourcePackage class])];

    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut =
        [[NSMutableArray alloc] initWithObjects:[resultFailBuilder build], nil];

    return (ADJOptionalFails<id<ADJSdkResponseData>> *)
        [ADJUnknownResponseData instanceWithBuilder:self
                                 unknownPackageData:self.sourcePackage
                                   optionalFailsMut:optionalFailsMut];
}

@end
