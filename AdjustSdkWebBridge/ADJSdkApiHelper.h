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
#import "ADJAdjustLaunchedDeeplink.h"
#import "ADJAdjustPushToken.h"
#import "ADJAdjustThirdPartySharing.h"
#import "ADJAdjustAdRevenue.h"

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
- (nullable NSArray *)eventCallbackParameterKeyValueArrayWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters;
- (nullable NSArray *)eventPartnerParameterKeyValueArrayWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters;

- (nonnull ADJAdjustLaunchedDeeplink *)adjustLaunchedDeeplinkWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters;

- (nonnull ADJAdjustPushToken *)adjustPushTokenWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters;

- (nonnull ADJAdjustThirdPartySharing *)adjustThirdPartySharingWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters;
- (nullable NSArray *)tpsGranulaOptionsByNameArrayWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters;
- (nullable NSArray *)tpsPartnerSharingSettingsByNameArrayWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters;

- (nonnull ADJAdjustAdRevenue *)adjustAdRevenueWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters;
- (nullable NSArray *)adRevenueCallbackParameterKeyValueArrayWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters;
- (nullable NSArray *)adRevenuePartnerParameterKeyValueArrayWithJsParameters:
    (nonnull NSDictionary<NSString *, id> *)jsParameters;

- (nullable NSString *)
    stringLoggedWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key
    from:(nonnull NSString *)from;

+ (nullable ADJResultFail *)
    objectMatchesWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    expectedName:(nonnull NSString *)expectedName;

+ (nonnull ADJResult<NSString *> *)
    stringWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key;

+ (nonnull ADJResult<ADJBooleanWrapper *> *)trueWithJsValue:(nullable id)jsValue;

+ (nonnull ADJResult<NSNumber *> *)
    numberWithJsParameters:(nonnull NSDictionary<NSString *, id> *)jsParameters
    key:(nonnull NSString *)key;

@end
