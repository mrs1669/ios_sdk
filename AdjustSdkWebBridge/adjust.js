var Adjust = {
instance: function(instanceId = null) {
    if (typeof instanceId === "string") {
        if (! this._instanceMap) {
            this._instanceMap = new Map();
        }

        if (! this._instanceMap.has(instanceId)) {
            this._instanceMap.set(instanceId, new AdjustInstance(instanceId));
        }

        return this._instanceMap.get(instanceId);
    } else {
        if (! this._defaultInstance) {
            this._defaultInstance = new AdjustInstance(null);
        }

        return this._defaultInstance;
    }
},

getSdkVersion: function() {
        const message = {
        action:'adjust_getSdkVersion',
        data: adjustEvent
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
    data: adjustConfig,
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
};

AdjustInstance.prototype.trackEvent = function(adjustEvent) {
    const message = {
    action:'adjust_trackEvent',
    data: adjustEvent
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.trackAdRevenue = function(adjustRevenue) {
    const message = {
    action:'adjust_trackAdRevenue',
    data: adjustRevenue
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.trackLaunchedDeeplink = function(url) {
    const message = {
    action:'adjust_trackDeeplink',
    data: url
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.trackPushToken = function(token) {
    const message = {
    action:'adjust_trackPushToken',
    data: token
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.switchToOfflineMode = function() {
    const message = {
    action:'adjust_switchToOfflineMode',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.switchBackToOnlineMode = function() {
    const message = {
    action:'adjust_switchBackToOnlineMode',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.inactivateSdk = function() {
    const message = {
    action:'adjust_inactivateSdk',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.reactivateSdk = function() {
    const message = {
    action:'adjust_reactivateSdk',
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
    key: key,
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.clearAllGlobalCallbackParameters = function() {
    const message = {
    action:'adjust_clearAllGlobalCallbackParameters',
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
    key: key,
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.clearAllGlobalPartnerParameters = function() {
    const message = {
    action:'adjust_clearAllGlobalPartnerParameters',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.gdprForgetMe = function() {
    const message = {
    action:'adjust_gdprForgetMe',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.trackThirdPartySharing = function(adjustThirdPartySharing) {
    const message = {
    action:'adjust_trackThirdPartySharing',
    data: adjustThirdPartySharing
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.teardown = function(adjustConfig) {
    const message = {
    action:'adjust_teardown',
    data: adjustConfig
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.appWentToTheBackgroundManualCall = function() {
    const message = {
    action:'adjust_appWentToTheBackgroundManualCall',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

AdjustInstance.prototype.appWentToTheForegroundManualCall = function() {
    const message = {
    action:'adjust_appWentToTheForegroundManualCall',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
}

function AdjustConfig(appToken, environment, legacy) {
    this.appToken = appToken;
    this.environment = environment;
    this.sendInBackground = null;
    this.logLevel = null;
    this.defaultTracker = null;
    this.openDeferredDeeplink = null;
    this.eventDeduplicationListLimit = null;
    this.externalDeviceId = null;
    this.coppaCompliantEnabled = null;
    this.urlStrategy = null;
    this.dataResidency = null;
    this.needsCost = null;
    this.customEndpointUrl = null;
    this.customEndpointPublicKeyHash = null;

    this.adjustAttributionChangedSubscriberCallbackId = null;
    this.adjustAttributionChangedSubscriberCallback = null;
    this.adjustAttributionReadSubscriberCallbackId = null;
    this.adjustAttributionReadSubscriberCallback = null;
    this.adjustIdentifierReadSubscriberCallbackId = null;
    this.adjustIdentifierReadSubscriberCallback = null;
    this.adjustIdentifierChangedSubscriberCallbackId = null;
    this.adjustIdentifierChangedSubscriberCallback = null;

}

AdjustConfig.EnvironmentSandbox = 'sandbox';
AdjustConfig.EnvironmentProduction = 'production';

AdjustConfig.UrlStrategyIndia = "INDIA";
AdjustConfig.UrlStrategyChina = "CHINA";

AdjustConfig.DataResidencyEU = "EU";
AdjustConfig.DataResidencyTR = "TR";
AdjustConfig.DataResidencyUS = "US";

AdjustConfig.LogLevelDebug = 'DEBUG',
AdjustConfig.LogLevelInfo = 'INFO',
AdjustConfig.LogLevelError = 'ERROR',

AdjustConfig.prototype.setSendInBackground = function(isEnabled) {
    this.sendInBackground = isEnabled;
};

AdjustConfig.prototype.setLogLevel = function(logLevel) {
    this.logLevel = logLevel;
};

AdjustConfig.prototype.setDefaultTracker = function(defaultTracker) {
    this.defaultTracker = defaultTracker;
};

AdjustConfig.prototype.setAdjustAttributionSubscriber = function(attributionReadCallback, attributionChangedCallback) {
    this.adjustAttributionReadSubscriberCallbackId =
        'setAdjustAttributionSubscriber_adjustAttributionRead';
    this.adjustAttributionReadSubscriberCallback = attributionReadCallback;

    this.adjustAttributionChangedSubscriberCallbackId =
        'setAdjustAttributionSubscriber_adjustAttributionChanged';
    this.adjustAttributionChangedSubscriberCallback = attributionChangedCallback;
};

AdjustConfig.prototype.setAdjustIdentifierSubscriber = function(adidReadCallback, adidChangeCallback) {
    this.adjustIdentifierReadSubscriberCallbackId =
        'setAdjustIdentifierSubscriber_adjustIdentifierRead';
    this.adjustIdentifierReadSubscriberCallback = adidReadCallback;

    this.adjustIdentifierChangedSubscriberCallbackId =
        'setAdjustIdentifierSubscriber_adjustIdentifierChanged';
    this.adjustIdentifierChangedSubscriberCallback = adidChangedCallback;
};

AdjustConfig.prototype.setOpenDeferredDeeplink = function(shouldOpen) {
    this.openDeferredDeeplink = shouldOpen;
};

AdjustConfig.prototype.allowSendingFromBackground = function() {
    this.sendInBackground = true;
};

AdjustConfig.prototype.setEventDeduplicationListLimit = function(limit) {
    this.eventDeduplicationListLimit = limit;
};

AdjustConfig.prototype.setExternalDeviceId = function(externalDevId){
    this.externalDeviceId = externalDevId;
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
