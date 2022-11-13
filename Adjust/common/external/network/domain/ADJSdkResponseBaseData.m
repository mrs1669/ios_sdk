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
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                         sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
                                 logger:(nonnull ADJLogger *)logger
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
    
    _serverMessage = [ADJNonEmptyString
                      instanceFromOptionalString:
                          [ADJUtilMap extractStringValueWithDictionary:_jsonDictionary
                                                                   key:ADJParamMessageKey]
                      sourceDescription:@"response message"
                      logger:logger];
    
    _adid = [ADJNonEmptyString
             instanceFromOptionalString:
                 [ADJUtilMap extractStringValueWithDictionary:_jsonDictionary
                                                          key:ADJParamAdidKey]
             sourceDescription:@"response adid"
             logger:logger];
    
    _trackingState =
        [ADJNonEmptyString
         instanceFromOptionalString:
             [ADJUtilMap extractStringValueWithDictionary:_jsonDictionary
                                                      key:ADJParamTrackingStateKey]
         sourceDescription:@"response tracking state"
         logger:logger];
    
    _timestampString =
        [ADJNonEmptyString
         instanceFromOptionalString:
             [ADJUtilMap extractStringValueWithDictionary:_jsonDictionary
                                                      key:ADJParamTimeSpentKey]
         sourceDescription:@"response timestamp"
         logger:logger];
    
    _askInIntMilli =
        [ADJNonNegativeInt
         instanceFromOptionalIntegerNumber:
             [ADJUtilMap extractIntegerNumberWithDictionary:_jsonDictionary
                                                        key:ADJParamAskInKey]
         logger:logger];
    
    _askIn = _askInIntMilli != nil ?
        [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:_askInIntMilli] : nil;
    
    _continueInIntMilli =
        [ADJNonNegativeInt
         instanceFromOptionalIntegerNumber:
             [ADJUtilMap extractIntegerNumberWithDictionary:_jsonDictionary
                                                        key:ADJParamContinueInKey]
         logger:logger];
    
    _continueIn = _continueInIntMilli != nil ?
        [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:_continueInIntMilli] : nil;
    
    _retryInIntMilli =
        [ADJNonNegativeInt
         instanceFromOptionalIntegerNumber:
             [ADJUtilMap extractIntegerNumberWithDictionary:_jsonDictionary
                                                        key:ADJParamRetryInKey]
         logger:logger];
    
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
