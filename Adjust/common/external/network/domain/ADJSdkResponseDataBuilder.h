//
//  ADJSdkResponseDataBuilder.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkPackageData.h"
#import "ADJStringMapBuilder.h"
#import "ADJSdkResponseData.h"
#import "ADJLogger.h"
#import "ADJSdkPackageSender.h"

@interface ADJSdkResponseDataBuilder : NSObject
// instantiation
- (nonnull instancetype)initWithSourceSdkPackage:(nonnull id<ADJSdkPackageData>)sourcePackage
                               sendingParameters:(nonnull ADJStringMapBuilder *)sendingParameters
                                  sourceCallback:(nonnull id<ADJSdkResponseCallbackSubscriber>)sourceCallback;

// public properties
@property (nonnull, readonly, strong, nonatomic) id<ADJSdkPackageData> sourcePackage;
@property (nonnull, readonly, strong, nonatomic) ADJStringMapBuilder *sendingParameters;
@property (nonnull, readonly, strong, nonatomic) id<ADJSdkResponseCallbackSubscriber> sourceCallback;
@property (nullable, readwrite, strong, nonatomic) NSDictionary *jsonDictionary;

// public api
- (BOOL)didReceiveJsonResponse;
/*
- (void)logErrorWithLogger:(nonnull ADJLogger *)logger
                resultFail:(nonnull id<ADJResultFail>)resultFail;
                   //nsError:(nullable NSError *)nsError
              //errorMessage:(nonnull NSString *)errorMessage;
*/
- (void)incrementRetries;

- (NSUInteger)retries;

- (nonnull id<ADJSdkResponseData>)buildSdkResponseDataWithLogger:(nullable ADJLogger *)logger;

@end

