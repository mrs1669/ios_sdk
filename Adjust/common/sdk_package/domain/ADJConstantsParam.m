//
//  ADJConstantsParam.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJConstantsParam.h"

// timestamps
NSString *const ADJParamCreatedAtKey = @"created_at";
NSString *const ADJParamCalledAtKey = @"called_at";

// params
NSString *const ADJParamCallbackParamsKey = @"callback_params";
NSString *const ADJParamPartnerParamsKey = @"partner_params";

// sending
NSString *const ADJParamSentAtKey = @"sent_at";
NSString *const ADJParamAttemptsKey = @"attempts";
NSString *const ADJParamQueueSizeKey = @"queue_size";

// client config
NSString *const ADJParamAppTokenKey = @"app_token";
NSString *const ADJParamEnvironmentKey = @"environment";
NSString *const ADJParamDefaultTrackerKey = @"default_tracker";
NSString *const ADJParamExternalDeviceIdKey = @"external_device_id";

// response
NSString *const ADJParamMessageKey = @"message";
NSString *const ADJParamAdidKey = @"adid";
NSString *const ADJParamTrackingStateKey = @"tracking_state";
NSString *const ADJParamTimstampKey = @"timestamp";
NSString *const ADJParamAskInKey = @"ask_in";
NSString *const ADJParamContinueInKey = @"continue_in";
NSString *const ADJParamRetryInKey = @"retry_in";
NSString *const ADJParamAttributionKey = @"attribution";
NSString *const ADJParamOptOutValue = @"opted_out";

// device ids
NSString *const ADJParamPersistentIosUuidKey = @"primary_dedupe_token";
NSString *const ADJParamIosUuidKey = @"secondary_dedupe_token";
// device info
NSString *const ADJParamIdfaKey = @"idfa";
NSString *const ADJParamFbAnonIdKey = @"fb_anon_id";
NSString *const ADJParamIdfvKey = @"idfv";
NSString *const ADJParamBundleIdKey = @"bundle_id";
NSString *const ADJParamAppVersionKey = @"app_version";
NSString *const ADJParamAppVersionShortKey = @"app_version_short";
NSString *const ADJParamDeviceTypeKey = @"device_type";
NSString *const ADJParamDeviceNameKey = @"device_name";
NSString *const ADJParamOsNameKey = @"os_name";
NSString *const ADJParamOsVersionKey = @"os_version";
NSString *const ADJParamLanguageKey = @"language";
NSString *const ADJParamCountryKey = @"country";
NSString *const ADJParamHardwareNameKey = @"hardware_name";
NSString *const ADJParamCpuTypeSubtypeKey = @"cpu_type_subtype";
NSString *const ADJParamOsBuildKey = @"os_build";

// sdk session
NSString *const ADJParamSessionCountKey = @"session_count";
NSString *const ADJParamSessionLengthKey = @"session_length";
NSString *const ADJParamTimeSpentKey = @"time_spent";

// ad revenue
NSString *const ADJParamAdRevenueSourceKey = @"source";
NSString *const ADJParamAdRevenueRevenueKey = @"revenue";
NSString *const ADJParamAdRevenueCurrencyKey = @"currency";
NSString *const ADJParamAdRevenueAdImpressionsCountKey = @"ad_impressions_count";
NSString *const ADJParamAdRevenueNetworkKey = @"ad_revenue_network";
NSString *const ADJParamAdRevenueUnitKey = @"ad_revenue_unit";
NSString *const ADJParamAdRevenuePlacementKey = @"ad_revenue_placement";

// attribution
NSString *const ADJParamAttributionInititedByKey = @"initiated_by";
NSString *const ADJParamAttributionInititedBySdkValue = @"sdk";
NSString *const ADJParamAttributionInititedByBackendValue = @"backend";
NSString *const ADJParamAttributionInititedBySdkAndBackendValue = @"backend_and_sdk";
NSString *const ADJParamAttributionTrackerTokenKey = @"tracker_token";
NSString *const ADJParamAttributionTrackerNameKey = @"tracker_name";
NSString *const ADJParamAttributionNetworkKey = @"network";
NSString *const ADJParamAttributionCampaignKey = @"campaign";
NSString *const ADJParamAttributionAdGroupKey = @"adgroup";
NSString *const ADJParamAttributionCreativeKey = @"creative";
NSString *const ADJParamAttributionClickLableKey = @"click_label";
NSString *const ADJParamAttributionDeeplinkKey = @"deeplink";
NSString *const ADJParamAttributionStateKey = @"state";
NSString *const ADJParamAttributionCostTypeKey = @"cost_type";
NSString *const ADJParamAttributionCostAmountKey = @"cost_amount";
NSString *const ADJParamAttributionCostCurrencyKey = @"cost_currency";

// sdk click
NSString *const ADJParamClickSourceKey = @"source";
NSString *const ADJParamDeeplinkClickSourceValue = @"deeplink";
NSString *const ADJParamDeeplinkKey = @"deeplink";
NSString *const ADJParamAsaAttributionClickSourceValue = @"apple_ads";
NSString *const ADJParamAsaAttributionTokenKey = @"attribution_token";
NSString *const ADJParamAsaAttributionReadAtKey = @"read_at";

// event
NSString *const ADJParamEventCountKey = @"event_count";
NSString *const ADJParamEventTokenKey = @"event_token";
NSString *const ADJParamEventRevenueKey = @"revenue";
NSString *const ADJParamEventCurrencyKey = @"currency";

// info
NSString *const ADJParamPushTokenKey = @"push_token";
NSString *const ADJParamPushTokenSourceKey = @"source";
NSString *const ADJParamPushTokenSourceValue = @"push";

// log
NSString *const ADJParamLogMessageKey = @"log_message";
NSString *const ADJParamLogLevelKey = @"log_level";
NSString *const ADJParamLogSourceKey = @"log_source";

// subscription
NSString *const ADJParamSubscriptionBillingStoreKey = @"billing_store";
NSString *const ADJParamSubscriptionBillingStoreValue = @"iOS";
NSString *const ADJParamSubscriptionPriceAmountKey = @"revenue";
NSString *const ADJParamSubscriptionPriceCurrencyKey = @"currency";
NSString *const ADJParamSubscriptionTransactionIdKey = @"transaction_id";
NSString *const ADJParamSubscriptionReceiptDataStringKey = @"receipt";
NSString *const ADJParamSubscriptionTransactionDateKey = @"transaction_date";
NSString *const ADJParamSubscriptionSalesRegionKey = @"sales_region";

// third party sharing
NSString *const ADJParamThirdPartySharingKey = @"sharing";
NSString *const ADJParamThirdPartySharingEnabledValue = @"enable";
NSString *const ADJParamThirdPartySharingDisabledValue = @"disable";
NSString *const ADJParamThirdPartySharingGranularOptionsKey = @"granular_third_party_sharing_options";

// test server params
NSString *const ADJParamTestServerCustomEndPointKey = @"test_server_custom_end_point";
NSString *const ADJParamTestServerAdjustEndPointKey = @"test_server_adjust_end_point";
