//
//  ADJConstantsParam.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// timestamps
FOUNDATION_EXPORT NSString *const ADJParamCreatedAtKey;
FOUNDATION_EXPORT NSString *const ADJParamCalledAtKey;

// params
FOUNDATION_EXPORT NSString *const ADJParamCallbackParamsKey;
FOUNDATION_EXPORT NSString *const ADJParamPartnerParamsKey;

// sending
FOUNDATION_EXPORT NSString *const ADJParamSentAtKey;
FOUNDATION_EXPORT NSString *const ADJParamAttemptsKey;
FOUNDATION_EXPORT NSString *const ADJParamQueueSizeKey;

// client config
FOUNDATION_EXPORT NSString *const ADJParamAppTokenKey;
FOUNDATION_EXPORT NSString *const ADJParamEnvironmentKey;
FOUNDATION_EXPORT NSString *const ADJParamDefaultTrackerKey;
FOUNDATION_EXPORT NSString *const ADJParamExternalDeviceIdKey;

// response
FOUNDATION_EXPORT NSString *const ADJParamMessageKey;
FOUNDATION_EXPORT NSString *const ADJParamAdidKey;
FOUNDATION_EXPORT NSString *const ADJParamTrackingStateKey;
FOUNDATION_EXPORT NSString *const ADJParamTimstampKey;
FOUNDATION_EXPORT NSString *const ADJParamAskInKey;
FOUNDATION_EXPORT NSString *const ADJParamContinueInKey;
FOUNDATION_EXPORT NSString *const ADJParamRetryInKey;
FOUNDATION_EXPORT NSString *const ADJParamAttributionKey;
FOUNDATION_EXPORT NSString *const ADJParamOptOutValue;

// device ids
FOUNDATION_EXPORT NSString *const ADJParamPersistentIosUuidKey;
FOUNDATION_EXPORT NSString *const ADJParamIosUuidKey;
// device info
FOUNDATION_EXPORT NSString *const ADJParamIdfaKey;
FOUNDATION_EXPORT NSString *const ADJParamFbAnonIdKey;
FOUNDATION_EXPORT NSString *const ADJParamIdfvKey;
FOUNDATION_EXPORT NSString *const ADJParamBundleIdKey;
FOUNDATION_EXPORT NSString *const ADJParamAppVersionKey;
FOUNDATION_EXPORT NSString *const ADJParamAppVersionShortKey;
FOUNDATION_EXPORT NSString *const ADJParamDeviceTypeKey;
FOUNDATION_EXPORT NSString *const ADJParamDeviceNameKey;
FOUNDATION_EXPORT NSString *const ADJParamOsNameKey;
FOUNDATION_EXPORT NSString *const ADJParamOsVersionKey;
FOUNDATION_EXPORT NSString *const ADJParamLanguageKey;
FOUNDATION_EXPORT NSString *const ADJParamCountryKey;
FOUNDATION_EXPORT NSString *const ADJParamHardwareNameKey;
FOUNDATION_EXPORT NSString *const ADJParamCpuTypeSubtypeKey;
FOUNDATION_EXPORT NSString *const ADJParamOsBuildKey;

// sdk session
FOUNDATION_EXPORT NSString *const ADJParamSessionCountKey;
FOUNDATION_EXPORT NSString *const ADJParamSessionLengthKey;
FOUNDATION_EXPORT NSString *const ADJParamTimeSpentKey;

// ad revenue
FOUNDATION_EXPORT NSString *const ADJParamAdRevenueSourceKey;
FOUNDATION_EXPORT NSString *const ADJParamAdRevenueRevenueKey;
FOUNDATION_EXPORT NSString *const ADJParamAdRevenueCurrencyKey;
FOUNDATION_EXPORT NSString *const ADJParamAdRevenueAdImpressionsCountKey;
FOUNDATION_EXPORT NSString *const ADJParamAdRevenueNetworkKey;
FOUNDATION_EXPORT NSString *const ADJParamAdRevenueUnitKey;
FOUNDATION_EXPORT NSString *const ADJParamAdRevenuePlacementKey;

// attribution
FOUNDATION_EXPORT NSString *const ADJParamAttributionInititedByKey;
FOUNDATION_EXPORT NSString *const ADJParamAttributionInititedBySdkValue;
FOUNDATION_EXPORT NSString *const ADJParamAttributionInititedByBackendValue;
FOUNDATION_EXPORT NSString *const ADJParamAttributionInititedBySdkAndBackendValue;
FOUNDATION_EXPORT NSString *const ADJParamAttributionTrackerTokenKey;
FOUNDATION_EXPORT NSString *const ADJParamAttributionTrackerNameKey;
FOUNDATION_EXPORT NSString *const ADJParamAttributionNetworkKey;
FOUNDATION_EXPORT NSString *const ADJParamAttributionCampaignKey;
FOUNDATION_EXPORT NSString *const ADJParamAttributionAdGroupKey;
FOUNDATION_EXPORT NSString *const ADJParamAttributionCreativeKey;
FOUNDATION_EXPORT NSString *const ADJParamAttributionClickLableKey;
FOUNDATION_EXPORT NSString *const ADJParamAttributionDeeplinkKey;
FOUNDATION_EXPORT NSString *const ADJParamAttributionStateKey;
FOUNDATION_EXPORT NSString *const ADJParamAttributionCostTypeKey;
FOUNDATION_EXPORT NSString *const ADJParamAttributionCostAmountKey;
FOUNDATION_EXPORT NSString *const ADJParamAttributionCostCurrencyKey;

// sdk click
FOUNDATION_EXPORT NSString *const ADJParamClickSourceKey;
FOUNDATION_EXPORT NSString *const ADJParamDeeplinkClickSourceValue;
FOUNDATION_EXPORT NSString *const ADJParamDeeplinkKey;
FOUNDATION_EXPORT NSString *const ADJParamAsaAttributionClickSourceValue;
FOUNDATION_EXPORT NSString *const ADJParamAsaAttributionTokenKey;
FOUNDATION_EXPORT NSString *const ADJParamAsaAttributionReadAtKey;

// event
FOUNDATION_EXPORT NSString *const ADJParamEventCountKey;
FOUNDATION_EXPORT NSString *const ADJParamEventTokenKey;
FOUNDATION_EXPORT NSString *const ADJParamEventRevenueKey;
FOUNDATION_EXPORT NSString *const ADJParamEventCurrencyKey;

// info
FOUNDATION_EXPORT NSString *const ADJParamPushTokenKey;
FOUNDATION_EXPORT NSString *const ADJParamPushTokenSourceKey;
FOUNDATION_EXPORT NSString *const ADJParamPushTokenSourceValue;

// log
FOUNDATION_EXPORT NSString *const ADJParamLogMessageKey;
FOUNDATION_EXPORT NSString *const ADJParamLogLevelKey;
FOUNDATION_EXPORT NSString *const ADJParamLogSourceKey;

// subscription
FOUNDATION_EXPORT NSString *const ADJParamSubscriptionBillingStoreKey;
FOUNDATION_EXPORT NSString *const ADJParamSubscriptionBillingStoreValue;
FOUNDATION_EXPORT NSString *const ADJParamSubscriptionPriceAmountKey;
FOUNDATION_EXPORT NSString *const ADJParamSubscriptionPriceCurrencyKey;
FOUNDATION_EXPORT NSString *const ADJParamSubscriptionTransactionIdKey;
FOUNDATION_EXPORT NSString *const ADJParamSubscriptionReceiptDataStringKey;
FOUNDATION_EXPORT NSString *const ADJParamSubscriptionTransactionDateKey;
FOUNDATION_EXPORT NSString *const ADJParamSubscriptionSalesRegionKey;

// third party sharing
FOUNDATION_EXPORT NSString *const ADJParamThirdPartySharingKey;
FOUNDATION_EXPORT NSString *const ADJParamThirdPartySharingEnabledValue;
FOUNDATION_EXPORT NSString *const ADJParamThirdPartySharingDisabledValue;
FOUNDATION_EXPORT NSString *const ADJParamThirdPartySharingGranularOptionsKey;
FOUNDATION_EXPORT NSString *const ADJParamThirdPartySharingPartnerSharingSettingsKey;

// test server params
FOUNDATION_EXPORT NSString *const ADJParamTestServerCustomEndPointKey;
FOUNDATION_EXPORT NSString *const ADJParamTestServerAdjustEndPointKey;

NS_ASSUME_NONNULL_END
