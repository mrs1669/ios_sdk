
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
    _postMessage(methodName, instanceId = "", parameters = "{}", errSubscriber) {
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
            methodName: methodName,
            instanceId: instanceId,
            parameters: parameters
        });
    },

    getSdkVersion: function() {
        Adjust.postMessage("getSdkVersion");
    },

    teardown: function() {
        this._instanceMap = undefined;
        // TODO reset js interface?
    },

};

function AdjustInstance(instanceId, errSubscriber) {
    this._instanceId = instanceId;
    this._errSubscriber = errSubscriber;
    this._callbackMap = new Map();
};

AdjustInstance.prototype._postMessage = function(methodName, parameters) {
    Adjust._postMessage(methodName, this._instanceId, parameters, this._errSubscriber); }

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
        this._postMessage("jsFail",
                          JSON.stringify({
            _message: errMessage,
            _callbackId: callbackId,
            _callbackIdType: typeof callbackId,
            _methodName: methodName,
            _methodNameType: typeof methodName,
            _callbackParameter: callbackParameter,
            _callbackParameterType: typeof callbackParameter,
            _callbackMapKeys: Array.from(this._callbackMap.keys())
        }));
        return;
    }

    callbackFunction(methodName, callbackParameter);
}


AdjustInstance.prototype.initSdk = function(adjustConfig) {
    // save permanent callbacks
    if (adjustConfig._adjustAttributionSubscriberCallbackId) {
        this._callbackMap.set(adjustConfig._adjustAttributionSubscriberCallbackId,
                              adjustConfig._adjustAttributionSubscriberCallback);
    }
    /*
    if (adjustConfig.adjustIdentifierSubscriberCallbackId) {
        this.callbacksMap.set(
          adjustConfig.adjustIdentifierSubscriberCallbackId,
          adjustConfig.adjustIdentifierSubscriberCallback);
    }

    if (adjustConfig.adjustLogSubscriberCallbackId) {
        this.callbacksMap.set(
          adjustConfig.adjustLogSubscriberCallbackId,
          adjustConfig.adjustLogSubscriberCallback);
    }
     */

    this._postMessage("initSdk", JSON.stringify(adjustConfig)); };

AdjustInstance.prototype.inactivateSdk = function() {
    this._postMessage("inactivateSdk"); }
AdjustInstance.prototype.reactivateSdk = function() {
    this._postMessage("reactivateSdk"); }

AdjustInstance.prototype.gdprForgetDevice = function() {
    this._postMessage("gdprForgetDevice"); }

AdjustInstance.prototype.appWentToTheBackgroundManualCall = function() {
    this._postMessage("appWentToTheBackgroundManualCall"); }
AdjustInstance.prototype.appWentToTheForegroundManualCall = function() {
    this._postMessage("appWentToTheForegroundManualCall"); }

AdjustInstance.prototype.switchToOfflineMode = function() {
    this._postMessage("switchToOfflineMode"); }
AdjustInstance.prototype.switchBackToOnlineMode = function() {
    this._postMessage("switchBackToOnlineMode"); }

AdjustInstance.prototype.trackLaunchedDeeplink = function(url) {
    this._postMessage("trackLaunchedDeeplink",
                      JSON.stringify({_url: url, _urlType: typeof url})); }

AdjustInstance.prototype.trackPushToken = function(pushToken) {
    this._postMessage("trackPushToken",
                      JSON.stringify({_pushToken: pushToken, _pushTokenType: typeof pushToken})); }

AdjustInstance.prototype.addGlobalCallbackParameter = function(key, value) {
    this._postMessage("addGlobalCallbackParameter",
                      JSON.stringify({
        _key: key, _keyType: typeof key,
        _value: value, _valueType: typeof value})); }
AdjustInstance.prototype.removeGlobalCallbackParameter = function(key) {
    this._postMessage("removeGlobalCallbackParameter", JSON.stringify({
        _key: key, _keyType: typeof key})); }
AdjustInstance.prototype.clearGlobalCallbackParameters = function() {
    this._postMessage("clearGlobalCallbackParameters"); }

AdjustInstance.prototype.addGlobalPartnerParameter = function(key, value) {
    this._postMessage("addGlobalPartnerParameter",
                      JSON.stringify({
        _key: key, _keyType: typeof key,
        _value: value, _valueType: typeof value})); }
AdjustInstance.prototype.removeGlobalPartnerParameter = function(key) {
    this._postMessage("removeGlobalPartnerParameter", JSON.stringify({
        _key: key, _keyType: typeof key})); }
AdjustInstance.prototype.clearGlobalPartnerParameters = function() {
    this._postMessage("clearGlobalPartnerParameters"); }

AdjustInstance.prototype.getAdjustAttributionAsync = function(adjustAttributionCallback) {
    const callbackIdWithRandomPrefix =
        this._callbackIdWithRandomPrefix('getAdjustAttributionAsync');

    this._callbackMap.set(callbackIdWithRandomPrefix, adjustAttributionCallback);

    this._postMessage("getAdjustAttributionAsync", JSON.stringify({
        _adjustAttributionAsyncGetterCallbackId: callbackIdWithRandomPrefix,
        _adjustAttributionAsyncGetterCallbackType: typeof adjustAttributionCallback}));
}

AdjustInstance.prototype.getAdjustDeviceIdsAsync = function(adjustDeviceIdsCallback) {
    const callbackIdWithRandomPrefix =
        this._callbackIdWithRandomPrefix('getAdjustDeviceIdsAsync');

    this._callbackMap.set(callbackIdWithRandomPrefix, adjustDeviceIdsCallback);

    this._postMessage("getAdjustDeviceIdsAsync", JSON.stringify({
        _adjustDeviceIdsAsyncGetterCallbackId: callbackIdWithRandomPrefix,
        _adjustDeviceIdsAsyncGetterCallbackType: typeof adjustDeviceIdsCallback}));
}

AdjustInstance.prototype._callbackIdWithRandomPrefix = function(suffix) {
    // taken from https://stackoverflow.com/a/8084248
    //  not ideal for "true" randomness, but for the purpose it should be ok
    const randomString = (Math.random() + 1).toString(36).substring(7);
    return suffix + '_' + randomString;
}

function AdjustConfig(appToken, environment) {
    this._appToken = appToken;
    this._appTokenType = typeof appToken;

    this._environment = environment;
    this._environmentType = typeof environment;

    this._defaultTracker = null;
    this._urlStrategy = null;
    this._customEndpointUrl = null;
    this._customEndpointPublicKeyHash = null;
    this._doLogAll = null;
    this._doNotLogAny = null;
    this._canSendInBackground = null;
    this._doNotOpenDeferredDeeplink = null;
    this._doNotReadAppleSearchAdsAttribution = null;
    this._eventIdDeduplicationMaxCapacity = null;
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
    this._defaultTrackerType = typeof defaultTracker; };

AdjustConfig.prototype.doLogAll = function() {
    this._doLogAll = true; };

AdjustConfig.prototype.doNotLogAny = function() {
    this._doNotLogAny = true; };

AdjustConfig.prototype.setUrlStrategy = function(urlStrategy) {
    this._urlStrategy = urlStrategy;
    this._urlStrategyType = typeof urlStrategy };

AdjustConfig.prototype.setCustomEndpoint = function(customEndpointUrl, optionalPublicKeyKeyHash) {
    this._customEndpointUrl = customEndpointUrl;
    this._customEndpointUrlType = typeof customEndpointUrl;
    this._customEndpointPublicKeyHash = optionalPublicKeyKeyHash;
    this._customEndpointPublicKeyHashType = typeof optionalPublicKeyKeyHash; };

AdjustConfig.prototype.preventOpenDeferredDeeplink = function() {
    this._doNotOpenDeferredDeeplink = true; };

AdjustConfig.prototype.doNotReadAppleSearchAdsAttribution = function() {
    this._doNotReadAppleSearchAdsAttribution = true; };

AdjustConfig.prototype.allowSendingFromBackground = function() {
    this._canSendInBackground = true; };

AdjustConfig.prototype.setEventIdDeduplicationMaxCapacity =
    function(eventIdDeduplicationMaxCapacity) {
        this._eventIdDeduplicationMaxCapacity = eventIdDeduplicationMaxCapacity;
        this._eventIdDeduplicationMaxCapacityType = typeof eventIdDeduplicationMaxCapacity; };

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

 /*
var Adjust = {
instance: function(instanceId = "") {
    if (! this._instanceMap) {
        this._instanceMap = new Map();
    }

    if (! (typeof instanceId === "string")) {
        instanceId = ""
    }

    if (! this._instanceMap.has(instanceId)) {
        this._instanceMap.set(instanceId, new AdjustInstance(instanceId));
    }

    return this._instanceMap.get(instanceId);
},

getSdkVersion: function() {
    const message = {
    action:'adjust_getSdkVersion',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

teardown: function() {
    this._instanceMap = undefined;
    // TODO reset js interface?
},
    
};

function AdjustInstance(instanceId) {
    this.instanceId = instanceId;
    this.callbacksMap = new Map();
};

AdjustInstance.prototype.initSDK = function(adjustConfig) {
    const message = {
    action:'adjust_initSdk',
    instanceId: this.instanceId,
    data: adjustConfig
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
};

AdjustInstance.prototype.trackEvent = function(adjustEvent) {
    const message = {
    action:'adjust_trackEvent',
    instanceId: this.instanceId,
    data: adjustEvent
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.trackAdRevenue = function(adjustRevenue) {
    const message = {
    action:'adjust_trackAdRevenue',
    instanceId: this.instanceId,
    data: adjustRevenue
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.trackLaunchedDeeplink = function(url) {
    const message = {
    action:'adjust_trackDeeplink',
    instanceId: this.instanceId,
    data: url
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.trackPushToken = function(token) {
    const message = {
    action:'adjust_trackPushToken',
    instanceId: this.instanceId,
    data: token
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.switchToOfflineMode = function() {
    const message = {
    action:'adjust_switchToOfflineMode',
    instanceId: this.instanceId
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.switchBackToOnlineMode = function() {
    const message = {
    action:'adjust_switchBackToOnlineMode',
    instanceId: this.instanceId
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.inactivateSdk = function() {
    const message = {
    action:'adjust_inactivateSdk',
    instanceId: this.instanceId
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.reactivateSdk = function() {
    const message = {
    action:'adjust_reactivateSdk',
    instanceId: this.instanceId
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.addGlobalCallbackParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        console.log('Passed key or value is not of string type');
        return;
    }
    const message = {
    action:'adjust_addGlobalCallbackParameter',
    instanceId: this.instanceId,
    key: key,
    value: value
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.removeGlobalCallbackParameter = function(key) {
    if (typeof key !== 'string') {
        console.log('Passed key is not of string type');
        return;
    }
    const message = {
    action:'adjust_removeGlobalCallbackParameterByKey',
    instanceId: this.instanceId,
    key: key,
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.clearAllGlobalCallbackParameters = function() {
    const message = {
    action:'adjust_clearAllGlobalCallbackParameters',
    instanceId: this.instanceId
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

AdjustInstance.prototype.addGlobalPartnerParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        console.log('Passed key or value is not of string type');
        return;
    }
    const message = {
    action:'adjust_addGlobalPartnerParameter',
    instanceId: this.instanceId,
    key: key,
    value: value
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.removeGlobalPartnerParameter = function(key) {
    if (typeof key !== 'string') {
        console.log('Passed key is not of string type');
        return;
    }
    const message = {
    action:'adjust_removeGlobalPartnerParameterByKey',
    instanceId: this.instanceId,
    key: key,
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.clearAllGlobalPartnerParameters = function() {
    const message = {
    action:'adjust_clearAllGlobalPartnerParameters',
    instanceId: this.instanceId
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.gdprForgetMe = function() {
    const message = {
    action:'adjust_gdprForgetMe',
    instanceId: this.instanceId
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.trackThirdPartySharing = function(adjustThirdPartySharing) {
    const message = {
    action:'adjust_trackThirdPartySharing',
    instanceId: this.instanceId,
    data: adjustThirdPartySharing
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.teardown = function() {
    const message = {
    action:'adjust_teardown',
    instanceId: this.instanceId
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.appWentToTheBackgroundManualCall = function() {
    const message = {
    action:'adjust_appWentToTheBackgroundManualCall',
    instanceId: this.instanceId
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.appWentToTheForegroundManualCall = function() {
    const message = {
    action:'adjust_appWentToTheForegroundManualCall',
    instanceId: this.instanceId
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

function AdjustConfig(appToken, environment, legacy) {
    this.appToken = appToken;
    this.environment = environment;
    this.sendInBackground = null;
    this.logLevel = null;
    this.defaultTracker = null;
    this.openDeferredDeeplinkDeactivated = null;
    this.eventDeduplicationListLimit = null;
    this.externalDeviceId = null;
    this.coppaCompliantEnabled = null;
    this.urlStrategy = null;
    this.dataResidency = null;
    this.needsCost = null;
    this.customEndpointUrl = null;
    this.customEndpointPublicKeyHash = null;

    this.attributionCallback = null;
}

AdjustConfig.EnvironmentSandbox = 'sandbox';
AdjustConfig.EnvironmentProduction = 'production';

AdjustConfig.UrlStrategyIndia = "INDIA";
AdjustConfig.UrlStrategyChina = "CHINA";

AdjustConfig.DataResidencyEU = "EU";
AdjustConfig.DataResidencyTR = "TR";
AdjustConfig.DataResidencyUS = "US";

AdjustConfig.LogLevelAll = 'ALL',
AdjustConfig.LogLevelDoNot = 'NO',

AdjustConfig.prototype.setSendInBackground = function(isEnabled) {
    this.sendInBackground = isEnabled;
};

AdjustConfig.prototype.setLogLevel = function(logLevel) {
    this.logLevel = logLevel;
};

AdjustConfig.prototype.setDefaultTracker = function(defaultTracker) {
    this.defaultTracker = defaultTracker;
};

AdjustConfig.prototype.setAttributionCallback = function(attributionCallback) {
    this.attributionCallback = attributionCallback;
};

AdjustConfig.prototype.doNotOpenDeferredDeeplink = function() {
    this.openDeferredDeeplinkDeactivated = true;
};

AdjustConfig.prototype.allowSendingFromBackground = function() {
    this.sendInBackground = true;
};

AdjustConfig.prototype.setEventDeduplicationListLimit = function(limit) {
    this.eventDeduplicationListLimit = limit;
};

AdjustConfig.prototype.setCoppaCompliantEnabled = function() {
    this.coppaCompliantEnabled = true;
};

AdjustConfig.prototype.setUrlStrategy = function(urlStrategy) {
    this.urlStrategy = urlStrategy;
};

AdjustConfig.prototype.setDataResidency = function(dataResidency) {
    this.dataResidency = dataResidency;
};

AdjustConfig.prototype.setNeedsCostEnabled = function(){
    this.needsCost = true;
};

AdjustConfig.prototype.setExternalDeviceId = function(externalDeviceId){
    this.externalDeviceId = externalDeviceId;
};

AdjustConfig.prototype.setCustomEndpoint = function(customEndpointUrl, optionalPublicKeyKeyHash) {
    this.customEndpointUrl = customEndpointUrl;
    this.customEndpointPublicKeyHash = optionalPublicKeyKeyHash
};

function AdjustEvent(eventId) {
    this.eventId = eventId;
    this.revenue = null;
    this.currency = null;
    this.deduplicationId = null;
    this.callbackParameters = [];
    this.partnerParameters = [];
}

AdjustEvent.prototype.setRevenue = function(revenue, currency) {
    this.revenue = revenue;
    this.currency = currency;
};

AdjustEvent.prototype.addCallbackParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        console.log('Passed key or value is not of string type');
        return;
    }
    this.callbackParameters.push(key);
    this.callbackParameters.push(value);
};

AdjustEvent.prototype.addPartnerParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        console.log('Passed key or value is not of string type');
        return;
    }
    this.partnerParameters.push(key);
    this.partnerParameters.push(value);
};

AdjustEvent.prototype.setDeduplicationId = function(deduplicationId) {
    this.deduplicationId = deduplicationId;
};

function AdjustAdRevenue(source) {
    this.source = source;
    this.revenue = null;
    this.currency = null;

    this.adRevenueUnit = null;
    this.adRevenueNetwork = null;
    this.adRevenuePlacement = null;

    this.adImpressionsCount = null;
    this.callbackParameters = [];
    this.partnerParameters = [];
}

AdjustAdRevenue.prototype.setAdRevenue = function(revenue, currency) {
    this.revenue = revenue;
    this.currency = currency;
};

AdjustAdRevenue.prototype.addCallbackParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        console.log('Passed key or value is not of string type');
        return;
    }
    this.callbackParameters.push(key);
    this.callbackParameters.push(value);
};

AdjustAdRevenue.prototype.addPartnerParameter = function(key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        console.log('Passed key or value is not of string type');
        return;
    }
    this.partnerParameters.push(key);
    this.partnerParameters.push(value);
};

AdjustAdRevenue.prototype.setAdImpressionsCount = function(adImpressionsCount) {
    this.adImpressionsCount = adImpressionsCount;
};

AdjustAdRevenue.prototype.setAdRevenueNetwork = function(adRevenueNetwork) {
    this.adRevenueNetwork = adRevenueNetwork;
};

AdjustAdRevenue.prototype.setAdRevenueUnit= function(adRevenueUnit) {
    this.adRevenueUnit = adRevenueUnit;
};

AdjustAdRevenue.prototype.setAdRevenuePlacement = function(adRevenuePlacement) {
    this.adRevenuePlacement = adRevenuePlacement;
};

function AdjustThirdPartySharing(isEnabled) {
    this.isEnabled = isEnabled;
    this.granularOptions = [];
    this.partnerSharingSettings = [];
}

AdjustThirdPartySharing.prototype.addGranularOption = function(partnerName, key, value) {
    this.granularOptions.push(partnerName);
    this.granularOptions.push(key);
    this.granularOptions.push(value);
};

AdjustThirdPartySharing.prototype.addPartnerSharingSettings = function(partnerName, key, value) {
    this.partnerSharingSettings.push(partnerName);
    this.partnerSharingSettings.push(key);
    this.partnerSharingSettings.push(value);
};
*/
