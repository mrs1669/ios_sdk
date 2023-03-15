//
//  ADJSdkResponseBaseData.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkResponseBaseData.h"

#import "ADJUtilMap.h"
#import "ADJConstantsParam.h"
#import "ADJUtilObj.h"
#import "ADJBooleanWrapper.h"

#pragma mark Fields
#pragma mark - Public properties
/* ADJSdkResponseData.h
 @property (readonly, assign, nonatomic) BOOL shouldRetry;
 @property (readonly, assign, nonatomic) BOOL processedByServer;
 @property (readonly, assign, nonatomic) BOOL hasBeenOptOut;
 
 @property (nonnull, readonly, strong, nonatomic) id<ADJSdkPackageData> sourcePackage;
 
 @property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *retryIn;
 @property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *continueIn;
 @property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *askIn;
 
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adid;
 
 @property (nullable, strong, nonatomic) NSDictionary *attributionJson;
 */

@interface ADJSdkResponseBaseData ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJStringMapBuilder *sendingParameters;
//@property (nullable, readonly, strong, nonatomic) NSString *errorMessages;
@property (nullable, readonly, strong, nonatomic) NSDictionary *jsonDictionary;

#pragma mark - Internal variables
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *serverMessage;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *trackingState;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *timestampString;
@property (nullable, readonly, strong, nonatomic) ADJNonNegativeInt *askInIntMilli;
@property (nullable, readonly, strong, nonatomic) ADJNonNegativeInt *continueInIntMilli;
@property (nullable, readonly, strong, nonatomic) ADJNonNegativeInt *retryInIntMilli;

@end

@implementation ADJSdkResponseBaseData
#pragma mark - Synthesize protocol properties
@synthesize processedByServer = _processedByServer;
@synthesize sourcePackage = _sourcePackage;
@synthesize retryIn = _retryIn;
@synthesize continueIn = _continueIn;
@synthesize askIn = _askIn;
@synthesize adid = _adid;
@synthesize attributionJson = _attributionJson;

#pragma mark Instantiation
- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    // prevents direct creation of instance, needs to be invoked by subclass
    if ([self isMemberOfClass:[ADJSdkResponseBaseData class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    
    self = [super init];
    
    _sourcePackage = sdkPackageData;
    _sendingParameters = sdkResponseDataBuilder.sendingParameters;
    //_errorMessages = [sdkResponseDataBuilder errorMessages];
    
    _jsonDictionary = sdkResponseDataBuilder.jsonDictionary;

    _serverMessage = [ADJSdkResponseBaseData
                      extractOptionalStringWithResponseJson:_jsonDictionary
                      key:ADJParamMessageKey
                      optionalFailsMut:optionalFailsMut];

    _adid = [ADJSdkResponseBaseData
             extractOptionalStringWithResponseJson:_jsonDictionary
             key:ADJParamAdidKey
             optionalFailsMut:optionalFailsMut];

    _trackingState = [ADJSdkResponseBaseData
                      extractOptionalStringWithResponseJson:_jsonDictionary
                      key:ADJParamTrackingStateKey
                      optionalFailsMut:optionalFailsMut];

    _timestampString = [ADJSdkResponseBaseData
                        extractOptionalStringWithResponseJson:_jsonDictionary
                        key:ADJParamTimeSpentKey
                        optionalFailsMut:optionalFailsMut];

    _askInIntMilli =
        [ADJSdkResponseBaseData
         extractOptionalIntWithResponseJson:_jsonDictionary
         key:ADJParamAskInKey
         optionalFailsMut:optionalFailsMut];
    
    _askIn = _askInIntMilli != nil ?
        [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:_askInIntMilli] : nil;
    
    _continueInIntMilli =
        [ADJSdkResponseBaseData
         extractOptionalIntWithResponseJson:_jsonDictionary
         key:ADJParamContinueInKey
         optionalFailsMut:optionalFailsMut];
    
    _continueIn = _continueInIntMilli != nil ?
        [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:_continueInIntMilli] : nil;
    
    _retryInIntMilli =
        [ADJSdkResponseBaseData
         extractOptionalIntWithResponseJson:_jsonDictionary
         key:ADJParamRetryInKey
         optionalFailsMut:optionalFailsMut];
    
    _retryIn = _retryInIntMilli != nil ?
        [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:_retryInIntMilli] : nil;
    
    _attributionJson =
        [ADJUtilMap extractDictionaryValueWithDictionary:_jsonDictionary
                                                 key:ADJParamAttributionKey];
    
    // is only considered processed by with a valid JSON
    //  AND if it did not received "retry_in"
    _processedByServer = _jsonDictionary != nil && _retryIn == nil;
    /*
    NSString *_Nonnull responseMessage = _serverMessage != nil ?
        [NSString stringWithFormat:@"Response message: %@", _serverMessage]
        : @"Without response message";
    
    if ([sdkResponseDataBuilder okResponseCode]) {
        [logger info:@"%@", responseMessage];
    } else {
        [logger error:@"%@", responseMessage];
    }
    */
    return self;
}
+ (nullable ADJNonEmptyString *)
    extractOptionalStringWithResponseJson:(nullable NSDictionary *)responseJson
    key:(nonnull NSString *)key
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    ADJResultNL<NSString *> *_Nonnull valueResult =
        [ADJUtilMap extractStringValueWithDictionary:responseJson key:key];
    if (valueResult.fail != nil) {
        ADJResultFailBuilder *_Nonnull resultFailBuilder =
            [[ADJResultFailBuilder alloc] initWithMessage:
             @"Cannot extract optional string field in response json"];
        [resultFailBuilder withKey:@"value fail"
                         otherFail:valueResult.fail];
        [resultFailBuilder withKey:@"key"
                       stringValue:key];
        [optionalFailsMut addObject:[resultFailBuilder build]];
    }

    ADJResultNL<ADJNonEmptyString *> *_Nonnull stringResult =
        [ADJNonEmptyString instanceFromOptionalString:valueResult.value];
    if (stringResult.fail != nil) {
        ADJResultFailBuilder *_Nonnull resultFailBuilder =
            [[ADJResultFailBuilder alloc] initWithMessage:
             @"Cannot parse optional string field in response json"];
        [resultFailBuilder withKey:@"string parse fail"
                         otherFail:stringResult.fail];
        [resultFailBuilder withKey:@"key"
                       stringValue:key];
        [optionalFailsMut addObject:[resultFailBuilder build]];
    }

    return stringResult.value;
}
+ (nullable ADJNonNegativeInt *)
    extractOptionalIntWithResponseJson:(nullable NSDictionary *)responseJson
    key:(nonnull NSString *)key
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    ADJResultNL<NSNumber *> *_Nonnull valueResult =
        [ADJUtilMap extractIntegerNumberWithDictionary:responseJson
                                                   key:key];
    if (valueResult.fail != nil) {
        ADJResultFailBuilder *_Nonnull resultFailBuilder =
            [[ADJResultFailBuilder alloc] initWithMessage:
             @"Cannot extract optional int field in response json"];
        [resultFailBuilder withKey:@"value fail"
                         otherFail:valueResult.fail];
        [resultFailBuilder withKey:@"key"
                       stringValue:key];
        [optionalFailsMut addObject:[resultFailBuilder build]];
    }

    ADJResultNL<ADJNonNegativeInt *> *_Nonnull intResult =
        [ADJNonNegativeInt instanceFromOptionalIntegerNumber:valueResult.value];
    if (intResult.fail != nil) {
        ADJResultFailBuilder *_Nonnull resultFailBuilder =
            [[ADJResultFailBuilder alloc] initWithMessage:
             @"Cannot parse optional non negative int field in response json"];
        [resultFailBuilder withKey:@"non negative int fail"
                         otherFail:intResult.fail];
        [resultFailBuilder withKey:@"key"
                       stringValue:key];
        [optionalFailsMut addObject:[resultFailBuilder build]];
    }

    return intResult.value;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - ADJSdkResponseData
// it should not retry if it failed to process locally
//  since retrying would not change the outcome
// otherwise, retry if it was not processed by the server
- (BOOL)shouldRetry {
    return ! self.processedByServer;
}

- (BOOL)hasBeenOptOut {
    if (self.trackingState == nil) {
        return NO;
    }
    
    return [ADJParamOptOutValue isEqualToString:self.trackingState.stringValue];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:@"SdkResponseData",
            @"shouldRetry", [ADJBooleanWrapper instanceFromBool:self.shouldRetry],
            @"processedByServer", [ADJBooleanWrapper instanceFromBool:self.processedByServer],
            @"hasBeenOptOut", [ADJBooleanWrapper instanceFromBool:self.hasBeenOptOut],
            @"sourcePackage", [self.sourcePackage generateShortDescription],
            @"sendingParameters", self.sendingParameters,
            //@"errorMessages", self.errorMessages,
            @"jsonDictionary", self.jsonDictionary,
            nil];
}

@end
