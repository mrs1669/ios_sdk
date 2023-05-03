//
//  ADJSdkApiHelper.h
//  Adjust
//
//  Created by Pedro Silva on 03.05.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJWebViewCallback.h"

#import "ADJAdjustConfig.h"
#import "ADJAdjustEvent.h"

#import "ADJResult.h"
#import "ADJBooleanWrapper.h"


@interface ADJSdkApiHelper : NSObject

- (nonnull instancetype)initWithLogger:(nonnull ADJLogger *)logger
                       webViewCallback:(nonnull ADJWebViewCallback *)webViewCallback;

- (nullable instancetype)init NS_UNAVAILABLE;

- (nonnull ADJAdjustConfig *)adjustConfigWithParametersJsonDictionary:
    (nonnull NSDictionary<NSString *, id> *)jsParameters;
- (nullable NSDictionary<NSString *, id<ADJInternalCallback>> *)
    extractInternalConfigSubscriptionsWithJsParameters:
        (nonnull NSDictionary<NSString *, id> *)jsParameters
    instanceIdString:(nonnull NSString *)instanceIdString;

- (nullable id<ADJInternalCallback>)
    attributionGetterInternalCallbackWithJsParameters:
        (nonnull NSDictionary<NSString *, id> *)jsParameters
    instanceIdString:(nonnull NSString *)instanceIdString;

- (nullable id<ADJInternalCallback>)
    deviceIdsGetterInternalCallbackWithJsParameters:
        (nonnull NSDictionary<NSString *, id> *)jsParameters
    instanceIdString:(nonnull NSString *)instanceIdString;

- (nonnull ADJAdjustEvent *)adjustEventWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters;


+ (nonnull ADJResult<NSString *> *)
    stringWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key;

+ (nonnull ADJResult<ADJBooleanWrapper *> *)
    trueWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key;

+ (nonnull ADJResult<NSNumber *> *)
    numberWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key;

@end
