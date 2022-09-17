//
//  ADJSdkPackageBuilder.m
//  Adjust
//
//  Created by Pedro Silva on 25.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkPackageBuilder.h"

#import "ADJUtilMap.h"
#import "ADJStringMapBuilder.h"
#import "ADJStringMap.h"
#import "ADJTimestampMilli.h"
#import "ADJConstantsParam.h"
#import "ADJTallyCounter.h"

#pragma mark Private class
@implementation ADJSdkPackageCreatingPublisher @end

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic)
 ADJSdkPackageCreatingPublisher *sdkPackageCreatingPublisher;
 */

#pragma mark Fields
@interface ADJSdkPackageBuilder ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJClock *clockWeak;
@property (nonnull, readonly, strong, nonatomic) NSString *clientSdk;
@property (nonnull, readonly, strong, nonatomic) ADJClientConfigData *clientConfigData;
@property (nullable, readonly, weak, nonatomic) ADJDeviceController *deviceControllerWeak;
@property (nullable, readonly, weak, nonatomic) ADJGlobalCallbackParametersStorage *globalCallbackParametersStorageWeak;
@property (nullable, readonly, weak, nonatomic) ADJGlobalPartnerParametersStorage *globalPartnerParametersStorageWeak;
@property (nullable, readonly, weak, nonatomic) ADJEventStateStorage *eventStateStorageWeak;
@property (nullable, readonly, weak, nonatomic) ADJMeasurementSessionStateStorage *measurementSessionStateStorageWeak;

@end

@implementation ADJSdkPackageBuilder
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                        clock:(nonnull ADJClock *)clock
                                    clientSdk:(nonnull NSString *)clientSdk
                             clientConfigData:(nonnull ADJClientConfigData *)clientConfigData
                             deviceController:(nonnull ADJDeviceController *)deviceController
              globalCallbackParametersStorage:(nonnull ADJGlobalCallbackParametersStorage *)globalCallbackParametersStorage
               globalPartnerParametersStorage:(nonnull ADJGlobalPartnerParametersStorage *)globalPartnerParametersStorage
                            eventStateStorage:(nonnull ADJEventStateStorage *)eventStateStorage
               measurementSessionStateStorage:(nonnull ADJMeasurementSessionStateStorage *)measurementSessionStateStorage {

    self = [super initWithLoggerFactory:loggerFactory source:@"SdkPackageBuilder"];
    _clockWeak = clock;
    _clientSdk = clientSdk;
    _clientConfigData = clientConfigData;
    _deviceControllerWeak = deviceController;
    _globalCallbackParametersStorageWeak = globalCallbackParametersStorage;
    _globalPartnerParametersStorageWeak = globalPartnerParametersStorage;
    _eventStateStorageWeak = eventStateStorage;
    _measurementSessionStateStorageWeak = measurementSessionStateStorage;

    _sdkPackageCreatingPublisher = [[ADJSdkPackageCreatingPublisher alloc] init];

    return self;
}

#pragma mark Public API

- (nonnull ADJAdRevenuePackageData *)buildAdRevenueWithClientData:(nonnull ADJClientAdRevenueData *)clientAdRevenueData
                                                     apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp {
    ADJStringMapBuilder *_Nonnull parametersBuilder = [self generateParametersBuilderWithPath:ADJAdRevenuePackageDataPath
                                                                                 apiTimestamp:apiTimestamp
                                                                  callbackParametersOverwrite:clientAdRevenueData.callbackParameters
                                                                   partnerParametersOverwrite:clientAdRevenueData.partnerParameters];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamAdRevenueSourceKey
                         packageParamValueSerializable:clientAdRevenueData.source];

    if (clientAdRevenueData.revenue != nil) {
        [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                       key:ADJParamAdRevenueRevenueKey
                             packageParamValueSerializable:clientAdRevenueData.revenue.amount];

        [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                       key:ADJParamAdRevenueCurrencyKey
                             packageParamValueSerializable:clientAdRevenueData.revenue.currency];
    }

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamAdRevenueAdImpressionsCountKey
                         packageParamValueSerializable:clientAdRevenueData.adImpressionsCount];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamAdRevenueNetworkKey
                         packageParamValueSerializable:clientAdRevenueData.adRevenueNetwork];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamAdRevenueUnitKey
                         packageParamValueSerializable:clientAdRevenueData.adRevenueUnit];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamAdRevenuePlacementKey
                         packageParamValueSerializable:clientAdRevenueData.adRevenuePlacement];

    ADJStringMap *_Nonnull parameters =
    [self publishAndGenerateParametersWithParametersBuilder:parametersBuilder
                                                       path:ADJAdRevenuePackageDataPath];

    return [[ADJAdRevenuePackageData alloc] initWithClientSdk:self.clientSdk
                                                   parameters:parameters];
}

- (nonnull ADJAttributionPackageData *)buildAttributionPackageWithInitiatedBy:(nullable NSString *)initatedBy {
    ADJStringMapBuilder *_Nonnull parametersBuilder = [self generateParametersBuilderWithPath:ADJAttributionPackageDataPath];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamAttributionInititedByKey
                                            constValue:initatedBy];

    ADJStringMap *_Nonnull parameters = [self publishAndGenerateParametersWithParametersBuilder:parametersBuilder
                                                                                           path:ADJAttributionPackageDataPath];

    return [[ADJAttributionPackageData alloc] initWithClientSdk:self.clientSdk
                                                     parameters:parameters];
}

- (nonnull ADJBillingSubscriptionPackageData *)buildBillingSubscriptionWithClientData:(nonnull ADJClientBillingSubscriptionData *)clientBillingSubscriptionData
                                                                         apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp {
    ADJStringMapBuilder *_Nonnull parametersBuilder =
    [self generateParametersBuilderWithPath:ADJBillingSubscriptionPackageDataPath
                               apiTimestamp:apiTimestamp
                callbackParametersOverwrite:clientBillingSubscriptionData.callbackParameters
                 partnerParametersOverwrite:clientBillingSubscriptionData.partnerParameters];

    [ADJUtilMap
     injectIntoPackageParametersWithBuilder:parametersBuilder
     key:ADJParamSubscriptionPriceAmountKey
     packageParamValueSerializable:clientBillingSubscriptionData.price.amount];

    [ADJUtilMap
     injectIntoPackageParametersWithBuilder:parametersBuilder
     key:ADJParamSubscriptionPriceCurrencyKey
     packageParamValueSerializable:clientBillingSubscriptionData.price.currency];

    [ADJUtilMap
     injectIntoPackageParametersWithBuilder:parametersBuilder
     key:ADJParamSubscriptionTransactionIdKey
     packageParamValueSerializable:clientBillingSubscriptionData.transactionId];

    [ADJUtilMap
     injectIntoPackageParametersWithBuilder:parametersBuilder
     key:ADJParamSubscriptionReceiptDataStringKey
     packageParamValueSerializable:clientBillingSubscriptionData.receiptDataString];

    [ADJUtilMap
     injectIntoPackageParametersWithBuilder:parametersBuilder
     key:ADJParamSubscriptionTransactionDateKey
     packageParamValueSerializable:clientBillingSubscriptionData.transactionTimestamp];

    [ADJUtilMap
     injectIntoPackageParametersWithBuilder:parametersBuilder
     key:ADJParamSubscriptionBillingStoreKey
     packageParamValueSerializable:clientBillingSubscriptionData.billingStore];

    [ADJUtilMap
     injectIntoPackageParametersWithBuilder:parametersBuilder
     key:ADJParamSubscriptionSalesRegionKey
     packageParamValueSerializable:clientBillingSubscriptionData.salesRegion];

    ADJStringMap *_Nonnull parameters =
    [self
     publishAndGenerateParametersWithParametersBuilder:parametersBuilder
     path:ADJBillingSubscriptionPackageDataPath];

    return [[ADJBillingSubscriptionPackageData alloc] initWithClientSdk:self.clientSdk
                                                             parameters:parameters];
}


- (nonnull ADJClickPackageData *)buildLaunchedDeeplinkClickWithClientData:(nonnull ADJClientLaunchedDeeplinkData *)clientLaunchedDeeplinkData
                                                             apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp {
    ADJStringMapBuilder *_Nonnull parametersBuilder = [self generateParametersBuilderWithPath:ADJClickPackageDataPath
                                                                                 apiTimestamp:apiTimestamp];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamClickSourceKey
                                            constValue:ADJParamDeeplinkClickSourceValue];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamDeeplinkKey
                         packageParamValueSerializable:clientLaunchedDeeplinkData.launchedDeeplink];

    ADJStringMap *_Nonnull parameters = [self publishAndGenerateParametersWithParametersBuilder:parametersBuilder
                                                                                           path:ADJClickPackageDataPath];

    return [[ADJClickPackageData alloc] initWithClientSdk:self.clientSdk
                                               parameters:parameters];
}

/** /
 - (nonnull ADJClickPackageData *)
 buildAsaAttributionClickWithToken:
 (nonnull ADJNonEmptyString *)asaAttibutionToken
 asaAttributionReadTimestamp:(nullable ADJTimestampMilli *)asaAttributionReadTimestamp
 {
 ADJStringMapBuilder *_Nonnull parametersBuilder =
 [self generateParametersBuilderWithPath:ADJClickPackageDataPath];

 [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
 key:ADJParamClickSourceKey
 constValue:ADJParamAsaAttributionClickSourceValue];

 [ADJUtilMap
 injectIntoPackageParametersWithBuilder:parametersBuilder
 key:ADJParamAsaAttributionTokenKey
 packageParamValueSerializable:asaAttibutionToken];

 [ADJUtilMap
 injectIntoPackageParametersWithBuilder:parametersBuilder
 key:ADJParamAsaAttributionReadAtKey
 packageParamValueSerializable:asaAttributionReadTimestamp];


 ADJStringMap *_Nonnull parameters =
 [self publishAndGenerateParametersWithParametersBuilder:parametersBuilder
 path:ADJClickPackageDataPath];

 return [[ADJClickPackageData alloc] initWithClientSdk:self.clientSdk
 parameters:parameters];
 }
 */

- (nonnull ADJEventPackageData *)buildEventPackageWithClientData:(nonnull ADJClientEventData *)clientEventData
                                                    apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp {

    ADJStringMapBuilder *_Nonnull parametersBuilder = [self generateParametersBuilderWithPath:ADJEventPackageDataPath
                                                                                 apiTimestamp:apiTimestamp
                                                                  callbackParametersOverwrite:clientEventData.callbackParameters
                                                                   partnerParametersOverwrite:clientEventData.partnerParameters];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamEventTokenKey
                         packageParamValueSerializable:clientEventData.eventId];

    if (clientEventData.revenue != nil) {
        [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                       key:ADJParamEventRevenueKey
                             packageParamValueSerializable:clientEventData.revenue.amount];

        [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                       key:ADJParamEventCurrencyKey
                             packageParamValueSerializable:clientEventData.revenue.currency];
    }

    ADJStringMap *_Nonnull parameters = [self publishAndGenerateParametersWithParametersBuilder:parametersBuilder
                                                                                           path:ADJEventPackageDataPath];

    return [[ADJEventPackageData alloc] initWithClientSdk:self.clientSdk
                                               parameters:parameters];
}

- (nonnull ADJInfoPackageData *)buildInfoPackageWithClientData:(nonnull ADJClientPushTokenData*)clientPushTokenData
                                                  apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp {
    ADJStringMapBuilder *_Nonnull parametersBuilder = [self generateParametersBuilderWithPath:ADJInfoPackageDataPath];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamPushTokenKey
                         packageParamValueSerializable:clientPushTokenData.pushTokenString];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamPushTokenSourceKey
                                            constValue:ADJParamPushTokenSourceValue];

    ADJStringMap *_Nonnull parameters = [self publishAndGenerateParametersWithParametersBuilder:parametersBuilder
                                                                                           path:ADJInfoPackageDataPath];

    return [[ADJInfoPackageData alloc] initWithClientSdk:self.clientSdk
                                              parameters:parameters];
}

/*

 - (nonnull ADJLogPackageData *)
 buildLogPackageWithMessage:(nonnull ADJNonEmptyString *)logMessage
 logLevel:(nonnull NSString *)logLevel
 logSource:(nonnull NSString *)logSource
 {
 ADJStringMapBuilder *_Nonnull parametersBuilder =
 [self generateParametersBuilderWithPath:ADJLogPackageDataPath];

 [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
 key:ADJParamLogMessageKey
 packageParamValueSerializable:logMessage];

 [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
 key:ADJParamLogLevelKey
 constValue:logLevel];

 [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
 key:ADJParamLogSourceKey
 constValue:logSource];

 ADJStringMap *_Nonnull parameters =
 [self publishAndGenerateParametersWithParametersBuilder:parametersBuilder
 path:ADJLogPackageDataPath];

 return [[ADJLogPackageData alloc] initWithClientSdk:self.clientSdk
 parameters:parameters];
 }
 */

- (nonnull ADJSessionPackageData *)buildSessionPackageWithDataToOverwrite:(nonnull ADJPackageSessionData *)packageSessionDataOverwrite {
    ADJStringMapBuilder *_Nonnull parametersBuilder = [self generateParametersBuilderWithPath:ADJSessionPackageDataPath
                                                                  packageSessionDataOverwrite:packageSessionDataOverwrite];

    ADJStringMap *_Nonnull parameters = [self publishAndGenerateParametersWithParametersBuilder:parametersBuilder
                                                                                           path:ADJSessionPackageDataPath];

    return [[ADJSessionPackageData alloc] initWithClientSdk:self.clientSdk
                                                 parameters:parameters];
}

- (nonnull ADJThirdPartySharingPackageData *)buildThirdPartySharingWithClientData:(nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData
apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp {

    ADJStringMapBuilder *_Nonnull parametersBuilder =
    [self generateParametersBuilderWithPath:ADJThirdPartySharingPackageDataPath
                               apiTimestamp:apiTimestamp];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamClickSourceKey
                                            constValue:ADJParamDeeplinkClickSourceValue];

    if (clientThirdPartySharingData.enabledOrElseDisabledSharing != nil) {
        if (clientThirdPartySharingData.enabledOrElseDisabledSharing.boolValue) {
            [ADJUtilMap
             injectIntoPackageParametersWithBuilder:parametersBuilder
             key:ADJParamThirdPartySharingKey
             constValue:ADJParamThirdPartySharingEnabledValue];
        } else {
            [ADJUtilMap
             injectIntoPackageParametersWithBuilder:parametersBuilder
             key:ADJParamThirdPartySharingKey
             constValue:ADJParamThirdPartySharingDisabledValue];
        }
    }

    [ADJUtilMap
     injectIntoPackageParametersWithBuilder:parametersBuilder
     key:ADJParamThirdPartySharingGranularOptionsKey
     packageParamValueSerializable:clientThirdPartySharingData.stringGranularOptionsByName];

    ADJStringMap *_Nonnull parameters =
    [self
     publishAndGenerateParametersWithParametersBuilder:parametersBuilder
     path:ADJThirdPartySharingPackageDataPath];

    return [[ADJThirdPartySharingPackageData alloc] initWithClientSdk:self.clientSdk
                                                           parameters:parameters];
}

//- (nonnull ADJGdprForgetPackageData *)buildGdprForgetPackage {
//    ADJStringMapBuilder *_Nonnull parametersBuilder =
//    [self generateParametersBuilderWithPath:ADJGdprForgetPackageDataPath];
//
//    ADJStringMap *_Nonnull parameters =
//    [self publishAndGenerateParametersWithParametersBuilder:parametersBuilder
//                                                       path:ADJGdprForgetPackageDataPath];
//
//    return [[ADJGdprForgetPackageData alloc] initWithClientSdk:self.clientSdk
//                                                    parameters:parameters];
//}

+ (void)injectSentAtWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                          sentAtTimestamp:(nullable ADJTimestampMilli *)sentAtTimestamp {

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamSentAtKey
                         packageParamValueSerializable:sentAtTimestamp];

}

+ (void)injectAttemptsWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                   attempts:(nullable ADJNonNegativeInt *)attempts {

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamAttemptsKey
                         packageParamValueSerializable:attempts];
}

+ (void)injectRemainingQueuSizeWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                  remainingQueueSize:(nullable ADJNonNegativeInt *)remainingQueueSize {

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamQueueSizeKey
                         packageParamValueSerializable:remainingQueueSize];
}

#pragma mark Internal Methods
- (nonnull ADJStringMapBuilder *)generateParametersBuilderWithPath:(nonnull NSString *)path {

    return [self generateParametersBuilderWithPath:path apiTimestamp:nil
                       callbackParametersOverwrite:nil
                        partnerParametersOverwrite:nil
                       packageSessionDataOverwrite:nil];
}

- (nonnull ADJStringMapBuilder *)generateParametersBuilderWithPath:(nonnull NSString *)path
                                                      apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp {

    return [self generateParametersBuilderWithPath:path
                                      apiTimestamp:apiTimestamp
                       callbackParametersOverwrite:nil
                        partnerParametersOverwrite:nil
                       packageSessionDataOverwrite:nil];
}

- (nonnull ADJStringMapBuilder *)generateParametersBuilderWithPath:(nonnull NSString *)path
                                       packageSessionDataOverwrite:(nonnull ADJPackageSessionData *)packageSessionDataOverwrite {

    return [self generateParametersBuilderWithPath:path
                                      apiTimestamp:nil
                       callbackParametersOverwrite:nil
                        partnerParametersOverwrite:nil
                       packageSessionDataOverwrite:packageSessionDataOverwrite];
}

- (nonnull ADJStringMapBuilder *)generateParametersBuilderWithPath:(nonnull NSString *)path
                                                      apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
                                       callbackParametersOverwrite:(nullable ADJStringMap *)callbackParametersOverwrite
                                        partnerParametersOverwrite:(nullable ADJStringMap *)partnerParametersOverwrite {

    return [self generateParametersBuilderWithPath:path
                                      apiTimestamp:nil
                       callbackParametersOverwrite:callbackParametersOverwrite
                        partnerParametersOverwrite:partnerParametersOverwrite
                       packageSessionDataOverwrite:nil];
}

- (nonnull ADJStringMapBuilder *)generateParametersBuilderWithPath:(nonnull NSString *)path
                                                      apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
                                       callbackParametersOverwrite:(nullable ADJStringMap *)callbackParametersOverwrite
                                        partnerParametersOverwrite:(nullable ADJStringMap *)partnerParametersOverwrite
                                       packageSessionDataOverwrite:(nullable ADJPackageSessionData *)packageSessionDataOverwrite {

    ADJStringMapBuilder *_Nonnull parametersBuilder = [[ADJStringMapBuilder alloc] initWithEmptyMap];

    [self injectTimestampsWithParametersBuilder:parametersBuilder
                                           path:path
                                   apiTimestamp:apiTimestamp];

    [self injectDeviceWithParametersBuilder:parametersBuilder
                                       path:path];

    [self injectClientConfigFieldsWithParametersBuilder:parametersBuilder
                                                   path:path];

    [self injectEventStateFieldsWithParametersBuilder:parametersBuilder
                                                 path:path];

    [self injectCallbackParametersFieldsWithParametersBuilder:parametersBuilder
                                                         path:path
                                  callbackParametersOverwrite:callbackParametersOverwrite];

    [self injectPartnerParametersFieldsWithParametersBuilder:parametersBuilder
                                                        path:path
                                  partnerParametersOverwrite:partnerParametersOverwrite];

    [self injectMeasurementSessionFieldsWithParametersBuilder:parametersBuilder
                                                         path:path
                                  packageSessionDataOverwrite:packageSessionDataOverwrite];

    return parametersBuilder;
}

- (void)injectTimestampsWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                         path:(nullable NSString *)path
                                 apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp {

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamCalledAtKey
                         packageParamValueSerializable:apiTimestamp];

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger error:@"Cannot inject %@ for package with %@ path"
         " without a reference to clock", ADJParamCreatedAtKey, path];
        return;
    }

    ADJTimestampMilli *_Nullable nowTimestamp =
    [clock nonMonotonicNowTimestampMilliWithLogger:self.logger];

    if (nowTimestamp == nil) {
        [self.logger error:@"Cannot inject %@ for package with %@ path"
         " without a now timestamp", ADJParamCreatedAtKey, path];
        return;
    }

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamCreatedAtKey
                         packageParamValueSerializable:nowTimestamp];
}

- (void)injectDeviceWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                     path:(nullable NSString *)path {

    ADJDeviceController *_Nullable deviceController = self.deviceControllerWeak;
    if (deviceController == nil) {
        [self.logger error:@"Cannot inject device info for package with %@ path"
         " without a reference to device controller", path];
        return;
    }

    ADJNonEmptyString *_Nullable keychainUuid = [deviceController keychainUuid];
    if (keychainUuid != nil) {
        [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                       key:ADJParamPersistentIosUuidKey
                             packageParamValueSerializable:keychainUuid];
    } else {
        [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                       key:ADJParamIosUuidKey
                             packageParamValueSerializable:[deviceController nonKeychainUuid]];
    }

    ADJSessionDeviceIdsData *_Nonnull sessionDeviceIdsData = [deviceController getSessionDeviceIdsSync];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamIdfaKey
                         packageParamValueSerializable:sessionDeviceIdsData.advertisingIdentifier];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamIdfvKey
                         packageParamValueSerializable:sessionDeviceIdsData.identifierForVendor];

    ADJDeviceInfoData *_Nonnull deviceInfoData = deviceController.deviceInfoData;

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamFbAnonIdKey
                         packageParamValueSerializable:deviceInfoData.fbAnonymousId];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamBundleIdKey
                         packageParamValueSerializable:deviceInfoData.bundeIdentifier];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamAppVersionKey
                         packageParamValueSerializable:deviceInfoData.bundleVersion];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamAppVersionShortKey
                         packageParamValueSerializable:deviceInfoData.bundleShortVersion];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamDeviceTypeKey
                         packageParamValueSerializable:deviceInfoData.deviceType];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamDeviceNameKey
                         packageParamValueSerializable:deviceInfoData.deviceName];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamOsNameKey
                         packageParamValueSerializable:deviceInfoData.osName];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamOsVersionKey
                         packageParamValueSerializable:deviceInfoData.systemVersion];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamLanguageKey
                         packageParamValueSerializable:deviceInfoData.languageCode];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamCountryKey
                         packageParamValueSerializable:deviceInfoData.countryCode];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamHardwareNameKey
                         packageParamValueSerializable:deviceInfoData.machineModel];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamCpuTypeSubtypeKey
                         packageParamValueSerializable:deviceInfoData.cpuTypeSubtype];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamOsBuildKey
                         packageParamValueSerializable:deviceInfoData.osBuild];
}

- (void)injectClientConfigFieldsWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                                 path:(nullable NSString *)path {
    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamAppTokenKey
                         packageParamValueSerializable:self.clientConfigData.appToken];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamEnvironmentKey
                         packageParamValueSerializable:[self.clientConfigData environment]];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamDefaultTrackerKey
                         packageParamValueSerializable:self.clientConfigData.defaultTracker];

    /* TODO
     UtilMap.injectIntoPackageParameters(packageParametersBuilder,
     ConstantsParam.DEFAULT_TRACKER_KEY,
     clientConfigData.defaultTracker);

     UtilMap.injectIntoPackageParameters(packageParametersBuilder,
     ConstantsParam.EXTERNAL_DEVICE_ID_KEY,
     clientConfigData.externalDeviceId);
     */
}

- (void)injectEventStateFieldsWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                               path:(nullable NSString *)path {
    ADJEventStateStorage *_Nullable eventStateStorage = self.eventStateStorageWeak;

    if (eventStateStorage == nil) {
        [self.logger error:@"Cannot inject event data"
         "for package with %@ path without a reference to event state storage", path];
        return;
    }

    ADJEventStateData *_Nonnull eventStateData = [eventStateStorage readOnlyStoredDataValue];

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamEventCountKey
                         packageParamValueSerializable:eventStateData.eventCount];
}


- (void)injectCallbackParametersFieldsWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                                       path:(nullable NSString *)path
                                callbackParametersOverwrite:(nullable ADJStringMap *)callbackParametersOverwrite {
    ADJGlobalCallbackParametersStorage *_Nullable globalCallbackParametersStorage = self.globalCallbackParametersStorageWeak;
    ADJStringMap *_Nullable globalCallbackParametersMap;

    if (globalCallbackParametersStorage == nil) {
        [self.logger error:@"Cannot inject global callback parameters for package with %@ path"
         " without a reference to global callback parameters storage", path];
        globalCallbackParametersMap = nil;
    } else {
        globalCallbackParametersMap = [globalCallbackParametersStorage allPairs];
    }

    [self injectMapParametersWithParametersBuilder:parametersBuilder
                                    overwritingMap:callbackParametersOverwrite
                                           baseMap:globalCallbackParametersMap
                                            mapKey:ADJParamCallbackParamsKey];
}

- (void)injectPartnerParametersFieldsWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                                      path:(nullable NSString *)path
                                partnerParametersOverwrite:(nullable ADJStringMap *)partnerParametersOverwrite {
    ADJGlobalPartnerParametersStorage *_Nullable globalPartnerParametersStorage = self.globalPartnerParametersStorageWeak;
    ADJStringMap *_Nullable globalPartnerParametersMap;

    if (globalPartnerParametersStorage == nil) {
        [self.logger error:@"Cannot inject global partner parameters for package with %@ path"
         " without a reference to global partner parameters storage", path];
        globalPartnerParametersMap = nil;
    } else {
        globalPartnerParametersMap = [globalPartnerParametersStorage allPairs];
    }

    [self injectMapParametersWithParametersBuilder:parametersBuilder
                                    overwritingMap:partnerParametersOverwrite
                                           baseMap:globalPartnerParametersMap
                                            mapKey:ADJParamPartnerParamsKey];
}

- (void)injectMapParametersWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                  overwritingMap:(nullable ADJStringMap *)overwritingMap
                                         baseMap:(nullable ADJStringMap *)baseMap
                                          mapKey:(nonnull NSString *)mapKey {

    ADJStringMap *_Nullable mergedMap = [ADJUtilMap mergeMapsWithBaseMap:baseMap
                                                          overwritingMap:overwritingMap];
    if (mergedMap == nil) {
        return;
    }

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:mapKey
                         packageParamValueSerializable:mergedMap];
}

- (void)injectMeasurementSessionFieldsWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                                       path:(nullable NSString *)path
                                packageSessionDataOverwrite:(nullable ADJPackageSessionData *)packageSessionDataOverwrite {

    ADJMeasurementSessionStateStorage *_Nullable measurementSessionStateStorage =
    self.measurementSessionStateStorageWeak;

    ADJMeasurementSessionData *_Nullable currentMeasurementSessionData =
    measurementSessionStateStorage != nil ?
    [measurementSessionStateStorage readOnlyStoredDataValue].measurementSessionData : nil;

    ADJTallyCounter *_Nullable sessionCountValue =
    packageSessionDataOverwrite != nil ?
    packageSessionDataOverwrite.sessionCount
    : currentMeasurementSessionData != nil ?
    currentMeasurementSessionData.sessionCount : nil;

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamSessionCountKey
                         packageParamValueSerializable:sessionCountValue];

    ADJTimeLengthMilli *_Nullable sessionLengthMilli =
    packageSessionDataOverwrite != nil ?
    packageSessionDataOverwrite.sessionLengthMilli
    : currentMeasurementSessionData != nil ?
    currentMeasurementSessionData.sessionLengthMilli : nil;

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamSessionLengthKey
                         packageParamValueSerializable:sessionLengthMilli];

    ADJTimeLengthMilli *_Nullable timeSpentMilli =
    packageSessionDataOverwrite != nil ?
    packageSessionDataOverwrite.timeSpentMilli
    : currentMeasurementSessionData != nil ?
    currentMeasurementSessionData.timeSpentMilli : nil;

    [ADJUtilMap injectIntoPackageParametersWithBuilder:parametersBuilder
                                                   key:ADJParamTimeSpentKey
                         packageParamValueSerializable:timeSpentMilli];
}

- (nonnull ADJStringMap *)publishAndGenerateParametersWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                                                       path:(nonnull NSString *)path {
    ADJStringMap *_Nonnull prePublishingParameters = [[ADJStringMap alloc] initWithStringMapBuilder:parametersBuilder];

    if (! self.sdkPackageCreatingPublisher.hasSubscribers) {
        return prePublishingParameters;
    }

    ADJStringMapBuilder *_Nonnull parametersToWriteFromSubscribers =
    [[ADJStringMapBuilder alloc] initWithEmptyMap];

    [self.sdkPackageCreatingPublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJSdkPackageCreatingSubscriber> _Nonnull subscriber) {
        [subscriber willCreatePackageWithClientSdk:self.clientSdk
                                              path:path
                                        parameters:prePublishingParameters
                                 parametersToWrite:parametersToWriteFromSubscribers];
    }];

    if (parametersToWriteFromSubscribers.isEmpty) {
        return prePublishingParameters;
    }

    [parametersBuilder addAllPairsWithStringMapBuilder:parametersToWriteFromSubscribers];

    return [[ADJStringMap alloc] initWithStringMapBuilder:parametersBuilder];
}

@end


