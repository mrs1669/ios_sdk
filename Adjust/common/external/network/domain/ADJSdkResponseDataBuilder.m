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
/*
 #import "ADJBillingSubscriptionPackageData.h"
 #import "ADJBillingSubscriptionResponseData.h"
 #import "ADJClickPackageData.h"
 #import "ADJClickResponseData.h"
 #import "ADJGdprForgetPackageData.h"
 #import "ADJGdprForgetResponseData.h"
 #import "ADJLogPackageData.h"
 #import "ADJLogResponseData.h"
 */
#import "ADJSessionPackageData.h"
#import "ADJSessionResponseData.h"
#import "ADJEventPackageData.h"
#import "ADJEventResponseData.h"
#import "ADJAdRevenuePackageData.h"
#import "ADJAdRevenueResponseData.h"
#import "ADJInfoResponseData.h"
#import "ADJInfoPackageData.h"

/*
 #import "ADJThirdPartySharingPackageData.h"
 #import "ADJThirdPartySharingResponseData.h"
 */
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
@property (readwrite, assign, nonatomic) BOOL failedToProcessLocally;
@property (readwrite, assign, nonatomic) BOOL okResponseCode;
@property (readwrite, assign, nonatomic) NSUInteger retries;
//@property (nullable, readwrite, strong, nonatomic) id jsonResponseFoundation;
@property (nullable, readwrite, strong, nonatomic) NSString *errorMessages;

@end

@implementation ADJSdkResponseDataBuilder
#pragma mark Instantiation
- (nonnull instancetype)initWithSourceSdkPackage:(nonnull id<ADJSdkPackageData>)sourcePackage
                               sendingParameters:(nonnull ADJStringMapBuilder *)sendingParameters
                                  sourceCallback:(nonnull id<ADJSdkResponseCallbackSubscriber>)sourceCallback
                           previousErrorMessages:(nullable NSString *)previousErrorMessages {
    self = [super init];
    _sourcePackage = sourcePackage;
    _sendingParameters = sendingParameters;
    _sourceCallback = sourceCallback;
    
    _jsonDictionary = nil;
    
    _failedToProcessLocally = NO;
    
    _okResponseCode = NO;
    
    //_jsonResponseFoundation = nil;
    
    _errorMessages = previousErrorMessages;
    
    return self;
}

#pragma mark Public API
- (BOOL)didReceiveJsonResponse {
    return self.jsonDictionary != nil;
}

- (void)logErrorWithLogger:(nullable ADJLogger *)logger
                   nsError:(nullable NSError *)nsError
              errorMessage:(nonnull NSString *)errorMessage {
    if (nsError != nil) {
        if (logger != nil) {
            [logger errorWithNSError:nsError message:@"%@", errorMessage];
        }
        
        [self appendErrorWithMessage:
         [NSString stringWithFormat:@"%@, with NSError: %@",
          errorMessage,
          [ADJUtilF errorFormat:nsError]]];
    } else {
        if (logger != nil) {
            [logger error:@"%@", errorMessage];
        }
        
        [self appendErrorWithMessage:
         [NSString stringWithFormat:@"Without NSError, %@", errorMessage]];
    }
}

- (void)cannotProcessLocally {
    self.failedToProcessLocally = YES;
}

- (void)setOkResponseCode {
    self.okResponseCode = YES;
}

- (void)incrementRetries {
    self.retries = self.retries + 1;
}

#define tryBuildResponse(packageClassType, responseClassType, packageDataName)  \
if ([self.sourcePackage isKindOfClass:[packageClassType class]]) {          \
return [[responseClassType alloc]                                       \
initWithBuilder:self                                        \
packageDataName:(packageClassType *)self.sourcePackage      \
logger:logger];                                             \
}                                                                           \

- (nonnull id<ADJSdkResponseData>)buildSdkResponseDataWithLogger:(nullable ADJLogger *)logger {

    /*
     tryBuildResponse(ADJBillingSubscriptionPackageData,
     ADJBillingSubscriptionResponseData,
     billingSubscriptionPackageData)
     tryBuildResponse(ADJClickPackageData, ADJClickResponseData, clickPackageData)
     tryBuildResponse(ADJGdprForgetPackageData, ADJGdprForgetResponseData, gdprForgetPackageData)
     tryBuildResponse(ADJLogPackageData, ADJLogResponseData, logPackageData)
     */
    tryBuildResponse(ADJAttributionPackageData, ADJAttributionResponseData, attributionPackageData)
    tryBuildResponse(ADJSessionPackageData, ADJSessionResponseData, sessionPackageData)
    tryBuildResponse(ADJEventPackageData, ADJEventResponseData, eventPackageData)
    tryBuildResponse(ADJAdRevenuePackageData, ADJAdRevenueResponseData, adRevenuePackageData)
    tryBuildResponse(ADJInfoPackageData, ADJInfoResponseData, infoPackageData)

    /*
     tryBuildResponse(ADJThirdPartySharingPackageData,
     ADJThirdPartySharingResponseData,
     thirdPartySharingPackageData)
     */
    if (logger != nil) {
        [logger error:@"Could not match source sdk package of: %@, to one of the know types."
         " Will still be created with unknown type", self.sourcePackage];
    }
    
    return [[ADJUnknownResponseData alloc] initWithBuilder:self
                                            sdkPackageData:self.sourcePackage
                                                    logger:logger];
}

- (void)appendErrorWithMessage:(nonnull NSString *)errorMessage {
    if (self.errorMessages != nil) {
        self.errorMessages =
        [NSString stringWithFormat:@"%@\n%@", self.errorMessages, errorMessage];
    } else {
        self.errorMessages = errorMessage;
    }
}

@end
