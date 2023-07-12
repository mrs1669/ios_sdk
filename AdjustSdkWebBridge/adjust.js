
var Adjust = {
instance: function(instanceId = "", errSubscriber) {
    if (! this._instanceMap) {
        this._instanceMap = new Map();
    }

    let instance = this._instanceMap.get(instanceId);
    if (instance) {
        return instance;
    }

    if (! (typeof errSubscriber === "function")) {
        errSubscriber = undefined;
    }

    if (! (typeof instanceId === "string")) {
        if (errSubscriber) {
            errSubscriber("undefined or string expected for instance id."
                          + " Instead received: " + typeof instanceId);
        }
        instanceId = "";
    }

    instance = new AdjustInstance(instanceId, errSubscriber);
    this._instanceMap.set(instanceId, instance);

    return instance;
},

    // TODO inject undefined instanceId and handle that on the native side
    _postMessage(methodName, instanceId = "", parameters = {}, errSubscriber) {
        if (! this._adjustMessageHandler) {
            function canSend(okCheck, errReason) {
                if (! okCheck) { if (errSubscriber) {
                    errSubscriber("Cannot send message to native sdk ".concat(errReason)); }}
                return okCheck;
            }
            const canSendSendToNative =
            canSend(window, "without valid: 'window'") &&
            canSend(window.webkit, "without valid: 'window.webkit'") &&
            canSend(window.webkit.messageHandlers,
                    "without valid: 'window.webkit.messageHandlers'") &&
            canSend(window.webkit.messageHandlers.adjust,
                    "without valid: 'window.webkit.messageHandlers.adjust'") &&
            canSend(window.webkit.messageHandlers.adjust.postMessage,
                    "without valid: 'window.webkit.messageHandlers.adjust.postMessage'") &&
            canSend(typeof window.webkit.messageHandlers.adjust.postMessage === "function",
                    "when 'window.webkit.messageHandlers.adjust.postMessage' is not a function");

            if (! canSendSendToNative) { return; }

            this._adjustMessageHandler = window.webkit.messageHandlers.adjust;
        }

        this._adjustMessageHandler.postMessage({
        _methodName: methodName,
        _instanceId: instanceId,
        _parameters: JSON.stringify(parameters)
        });
    },

_getSdkVersionAsync: function(getSdkVersionCallback) {
    this._getSdkVersionCallback = getSdkVersionCallback;

    this._postMessage("getSdkVersionAsync", "", {
    _getSdkVersionCallbackId: "_getSdkVersionCallback",
        _getSdkVersionCallbackType: typeof getSdkVersionCallback});
},

_teardown: function() {
    this._instanceMap = undefined;
    this._adjustMessageHandler = undefined;
    this._getSdkVersionCallback = undefined;
},

};

function AdjustInstance(instanceId, errSubscriber) {
    this._instanceId = instanceId;
    this._errSubscriber = errSubscriber;
    this._callbackMap = new Map();
};

AdjustInstance.prototype._postMessage = function(methodName, parameters) {
    Adjust._postMessage(methodName, this._instanceId, parameters, this._errSubscriber);
}

AdjustInstance.prototype.adjust_clientSubscriber =
function(callbackId, methodName, callbackParameter) {
    this.adjust_clientCallback(false, "Could not find valid client subscriber callback function",
                               callbackId, methodName, callbackParameter);
}

AdjustInstance.prototype.adjust_clientGetter =
function(callbackId, methodName, callbackParameter) {
    this.adjust_clientCallback(true, "Could not find valid client getter callback function",
                               callbackId, methodName, callbackParameter);
}

AdjustInstance.prototype.adjust_clientCallback =
function(deleteAfter, errMessage, callbackId, methodName, callbackParameter) {
    const callbackFunction = this._callbackMap.get(callbackId);
    if (deleteAfter) {
        this._callbackMap.delete(callbackId);
    }

    if (! callbackFunction) {
        this._postMessage("jsFail", {
        _message: errMessage,
        _callbackId: callbackId,
        _callbackIdType: typeof callbackId,
        _methodName: methodName,
        _methodNameType: typeof methodName,
        _callbackParameter: callbackParameter,
        _callbackParameterType: typeof callbackParameter,
            _callbackMapKeys: Array.from(this._callbackMap.keys())});
        return;
    }

    callbackFunction(methodName, callbackParameter);
}

AdjustInstance.prototype.initSdk = function(adjustConfig) {
    // save permanent callbacks
    if (adjustConfig._adjustIdentifierSubscriberCallbackId) {
        this._callbackMap.set(adjustConfig._adjustIdentifierSubscriberCallbackId,
                              adjustConfig._adjustIdentifierSubscriberCallback);
    }

    if (adjustConfig._adjustAttributionSubscriberCallbackId) {
        this._callbackMap.set(adjustConfig._adjustAttributionSubscriberCallbackId,
                              adjustConfig._adjustAttributionSubscriberCallback);
    }

    this._postMessage("initSdk", adjustConfig);
};

AdjustInstance.prototype.inactivateSdk = function() {
    this._postMessage("inactivateSdk");
}

AdjustInstance.prototype.reactivateSdk = function() {
    this._postMessage("reactivateSdk");
}

AdjustInstance.prototype.gdprForgetDevice = function() {
    this._postMessage("gdprForgetDevice");
}

AdjustInstance.prototype.appWentToTheBackgroundManualCall = function() {
    this._postMessage("appWentToTheBackgroundManualCall");
}

AdjustInstance.prototype.appWentToTheForegroundManualCall = function() {
    this._postMessage("appWentToTheForegroundManualCall");
}

AdjustInstance.prototype.switchToOfflineMode = function() {
    this._postMessage("switchToOfflineMode");
}

AdjustInstance.prototype.switchBackToOnlineMode = function() {
    this._postMessage("switchBackToOnlineMode");
}

AdjustInstance.prototype.activateMeasurementConsent = function() {
    this._postMessage("activateMeasurementConsent");
}

AdjustInstance.prototype.inactivateMeasurementConsent = function() {
    this._postMessage("inactivateMeasurementConsent");
}

AdjustInstance.prototype.getAdjustDeviceIdsAsync = function(adjustDeviceIdsCallback) {
    const callbackIdWithRandomPrefix =
    this._callbackIdWithRandomPrefix("getAdjustDeviceIdsAsync");

    this._callbackMap.set(callbackIdWithRandomPrefix, adjustDeviceIdsCallback);

    this._postMessage("getAdjustDeviceIdsAsync", {
    _adjustDeviceIdsAsyncGetterCallbackId: callbackIdWithRandomPrefix,
        _adjustDeviceIdsAsyncGetterCallbackType: typeof adjustDeviceIdsCallback});
}

AdjustInstance.prototype.getAdjustIdentifierAsync = function(adjustIdentifierCallback) {
    const callbackIdWithRandomPrefix =
        this._callbackIdWithRandomPrefix("getAdjustIdentifierAsync");

    this._callbackMap.set(callbackIdWithRandomPrefix, adjustIdentifierCallback);

    this._postMessage("getAdjustIdentifierAsync", {
        _adjustIdentifierAsyncGetterCallbackId: callbackIdWithRandomPrefix,
        _adjustIdentifierAsyncGetterCallbackType: typeof adjustIdentifierCallback});
}

AdjustInstance.prototype.getAdjustAttributionAsync = function(adjustAttributionCallback) {
    const callbackIdWithRandomPrefix =
    this._callbackIdWithRandomPrefix("getAdjustAttributionAsync");

    this._callbackMap.set(callbackIdWithRandomPrefix, adjustAttributionCallback);

    this._postMessage("getAdjustAttributionAsync", {
    _adjustAttributionAsyncGetterCallbackId: callbackIdWithRandomPrefix,
        _adjustAttributionAsyncGetterCallbackType: typeof adjustAttributionCallback});
}

AdjustInstance.prototype.sendEvent = function(adjustEvent) {
    this._postMessage("sendEvent", adjustEvent);
};

AdjustInstance.prototype.sendLaunchedDeeplink = function(urlString) {
    this._postMessage("sendLaunchedDeeplink", {
        _urlString: urlString, _urlStringType: typeof urlString});
}

AdjustInstance.prototype.sendPushToken = function(pushTokenString) {
    this._postMessage("sendPushToken", {
        _pushTokenString: pushTokenString, _pushTokenStringType: typeof pushTokenString});
}

AdjustInstance.prototype.sendThirdPartySharing = function(adjustThirdPartySharing) {
    this._postMessage("sendThirdPartySharing", adjustThirdPartySharing);
};

AdjustInstance.prototype.sendAdRevenue = function(adjustAdRevenue) {
    this._postMessage("sendAdRevenue", adjustAdRevenue);
};

AdjustInstance.prototype.addGlobalCallbackParameter = function(key, value) {
    this._postMessage("addGlobalCallbackParameter", {
    _key: key, _keyType: typeof key,
        _value: value, _valueType: typeof value});
}

AdjustInstance.prototype.removeGlobalCallbackParameter = function(key) {
    this._postMessage("removeGlobalCallbackParameter", {_key: key, _keyType: typeof key});
}

AdjustInstance.prototype.clearGlobalCallbackParameters = function() {
    this._postMessage("clearGlobalCallbackParameters");
}

AdjustInstance.prototype.addGlobalPartnerParameter = function(key, value) {
    this._postMessage("addGlobalPartnerParameter", {
    _key: key, _keyType: typeof key,
        _value: value, _valueType: typeof value});
}

AdjustInstance.prototype.removeGlobalPartnerParameter = function(key) {
    this._postMessage("removeGlobalPartnerParameter", {_key: key, _keyType: typeof key});
}

AdjustInstance.prototype.clearGlobalPartnerParameters = function() {
    this._postMessage("clearGlobalPartnerParameters");
}


AdjustInstance.prototype._callbackIdWithRandomPrefix = function(suffix) {
    // taken from https://stackoverflow.com/a/8084248
    //  not ideal for "true" randomness, but for the purpose it should be ok
    const randomString = (Math.random() + 1).toString(36).substring(7);
    return suffix + "_" + randomString;
}

function AdjustConfig(appToken, environment) {
    this._objectName = "AdjustConfig";
    this._appToken = appToken;
    this._appTokenType = typeof appToken;

    this._environment = environment;
    this._environmentType = typeof environment;

    this._defaultTracker = null;
    this._urlStrategy = null;
    this._customEndpointUrl = null;
    this._customEndpointPublicKeyHash = null;
    this._isCoppaComplianceEnabled = null;
    this._doLogAll = null;
    this._doNotLogAny = null;
    this._canSendInBackground = null;
    this._doNotOpenDeferredDeeplink = null;
    this._doNotReadAppleSearchAdsAttribution = null;
    this._eventIdDeduplicationMaxCapacity = null;
    this._adjustIdentifierSubscriberCallbackId = null;
    this._adjustIdentifierSubscriberCallback = null;
    this._adjustAttributionSubscriberCallbackId = null;
    this._adjustAttributionSubscriberCallback = null;
    this._adjustLogSubscriberCallbackId = null;
    this._adjustLogSubscriberCallback = null;
}

AdjustConfig.EnvironmentSandbox = "sandbox";
AdjustConfig.EnvironmentProduction = "production";

AdjustConfig.UrlStrategyIndia = "INDIA";
AdjustConfig.UrlStrategyChina = "CHINA";

AdjustConfig.DataResidencyEU = "EU";
AdjustConfig.DataResidencyTR = "TR";
AdjustConfig.DataResidencyUS = "US";


AdjustConfig.prototype.setDefaultTracker = function(defaultTracker) {
    this._defaultTracker = defaultTracker;
    this._defaultTrackerType = typeof defaultTracker;
};

AdjustConfig.prototype.enableCoppaCompliance = function() {
    this._isCoppaComplianceEnabled = true;
};

AdjustConfig.prototype.doLogAll = function() {
    this._doLogAll = true;
};

AdjustConfig.prototype.doNotLogAny = function() {
    this._doNotLogAny = true;
};

AdjustConfig.prototype.setUrlStrategy = function(urlStrategy) {
    this._urlStrategy = urlStrategy;
    this._urlStrategyType = typeof urlStrategy
};

AdjustConfig.prototype.setCustomEndpoint = function(customEndpointUrl, optionalPublicKeyKeyHash) {
    this._customEndpointUrl = customEndpointUrl;
    this._customEndpointUrlType = typeof customEndpointUrl;
    this._customEndpointPublicKeyHash = optionalPublicKeyKeyHash;
    this._customEndpointPublicKeyHashType = typeof optionalPublicKeyKeyHash;
};

AdjustConfig.prototype.preventOpenDeferredDeeplink = function() {
    this._doNotOpenDeferredDeeplink = true;
};

AdjustConfig.prototype.doNotReadAppleSearchAdsAttribution = function() {
    this._doNotReadAppleSearchAdsAttribution = true;
};

AdjustConfig.prototype.allowSendingFromBackground = function() {
    this._canSendInBackground = true;
};

AdjustConfig.prototype.setEventIdDeduplicationMaxCapacity =
function(eventIdDeduplicationMaxCapacity) {
    this._eventIdDeduplicationMaxCapacity = eventIdDeduplicationMaxCapacity;
    this._eventIdDeduplicationMaxCapacityType = typeof eventIdDeduplicationMaxCapacity;
};

AdjustConfig.prototype.setAdjustIdentifierSubscriber = function(adjustIdentifierSubscriber) {
    this._adjustIdentifierSubscriberCallbackType = typeof adjustIdentifierSubscriber;
    this._adjustIdentifierSubscriberCallbackId = "adjustIdentifierSubscriberCallback";
    this._adjustIdentifierSubscriberCallback =  adjustIdentifierSubscriber;
};

AdjustConfig.prototype.setAdjustAttributionSubscriber = function(adjustAttributionSubscriber) {
    this._adjustAttributionSubscriberCallbackType = typeof adjustAttributionSubscriber;
    this._adjustAttributionSubscriberCallbackId = "adjustAttributionSubscriberCallback";
    this._adjustAttributionSubscriberCallback =  adjustAttributionSubscriber;
};

AdjustConfig.prototype.setAdjustLogSubscriber = function(adjustLogSubscriber) {
    this.adjustLogSubscriberCallbackType = typeof adjustLogSubscriberCallback;
    this.adjustLogSubscriberCallbackId = "adjustLogSubscriberCallback";
    this.adjustLogSubscriberCallback =  adjustLogSubscriberCallback;
};

function AdjustEvent(eventToken) {
    this._objectName = "AdjustEvent";
    this._eventToken = eventToken;
    this._eventTokenType = typeof eventToken;

    this._revenueAmountDouble = null;
    this._currency = null;
    this._callbackParameterKeyValueArray = [];
    this._partnerParameterKeyValueArray = [];
    this._deduplicationId = null;
}

AdjustEvent.prototype.setRevenueDouble = function(revenueAmountDouble, currency) {
    this._revenueAmountDouble = revenueAmountDouble;
    this._revenueAmountDoubleType = typeof revenueAmountDouble;
    this._currency = currency;
    this._currencyType = typeof currency;
};

AdjustEvent.prototype.addCallbackParameter = function(key, value) {
    this._callbackParameterKeyValueArray.push({_element: key, _elementType: typeof key});
    this._callbackParameterKeyValueArray.push({_element: value, _elementType: typeof value});
};

AdjustEvent.prototype.addPartnerParameter = function(key, value) {
    this._partnerParameterKeyValueArray.push({_element: key, _elementType: typeof key});
    this._partnerParameterKeyValueArray.push({_element: value, _elementType: typeof value});
};

AdjustEvent.prototype.setDeduplicationId = function(deduplicationId) {
    this._deduplicationId = deduplicationId;
    this._deduplicationIdType = typeof deduplicationId;
};


function AdjustThirdPartySharing() {
    this._objectName = "AdjustThirdPartySharing";
    this._enabledOrElseDisabledSharing = null;
    this._granularOptionsByNameArray = [];
    this._partnerSharingSettingsByNameArray = [];
}

AdjustThirdPartySharing.prototype.enableThirdPartySharing = function() {
    this._enabledOrElseDisabledSharing = true;
};

AdjustThirdPartySharing.prototype.disableThirdPartySharing = function() {
    this._enabledOrElseDisabledSharing = false;
};

AdjustThirdPartySharing.prototype.addGranularOption = function(partnerName, key, value) {
    this._granularOptionsByNameArray.push({
        _element: partnerName, _elementType: typeof partnerName});
    this._granularOptionsByNameArray.push({_element: key, _elementType: typeof key});
    this._granularOptionsByNameArray.push({_element: value, _elementType: typeof value});
};

AdjustThirdPartySharing.prototype.addPartnerSharingSetting = function(partnerName, key, value) {
    this._partnerSharingSettingsByNameArray.push({
        _element: partnerName, _elementType: typeof partnerName});
    this._partnerSharingSettingsByNameArray.push({_element: key, _elementType: typeof key});
    this._partnerSharingSettingsByNameArray.push({_element: value, _elementType: typeof value});
};


function AdjustAdRevenue(source) {
    this._objectName = "AdjustAdRevenue";
    this._source = source;
    this._sourceType = typeof source;

    this._revenueAmountDouble = null;
    this._currency = null;
    this._adImpressionsCount = null;
    this._network = null;
    this._unit = null;
    this._placement = null;
    this._callbackParameterKeyValueArray = [];
    this._partnerParameterKeyValueArray = [];
}

AdjustAdRevenue.prototype.setRevenueDouble = function(revenueAmountDouble, currency) {
    this._revenueAmountDouble = revenueAmountDouble;
    this._revenueAmountDoubleType = typeof revenueAmountDouble;
    this._currency = currency;
    this._currencyType = typeof currency;
};

AdjustAdRevenue.prototype.setAdImpressionsCount = function(adImpressionsCount) {
    this._adImpressionsCount = adImpressionsCount;
    this._adImpressionsCountType = typeof adImpressionsCount;
};

AdjustAdRevenue.prototype.setNetwork = function(network) {
    this._network = network;
    this._networkType = typeof network;
};

AdjustAdRevenue.prototype.setUnit = function(unit) {
    this._unit = unit;
    this._unitType = typeof unit;
};

AdjustAdRevenue.prototype.setPlacement = function(placement) {
    this._placement = placement;
    this._placementType = typeof placement;
};

AdjustAdRevenue.prototype.addCallbackParameter = function(key, value) {
    this._callbackParameterKeyValueArray.push({_element: key, _elementType: typeof key});
    this._callbackParameterKeyValueArray.push({_element: value, _elementType: typeof value});
};

AdjustAdRevenue.prototype.addPartnerParameter = function(key, value) {
    this._partnerParameterKeyValueArray.push({_element: key, _elementType: typeof key});
    this._partnerParameterKeyValueArray.push({_element: value, _elementType: typeof value});
};

