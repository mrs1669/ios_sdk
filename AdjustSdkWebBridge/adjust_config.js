function AdjustConfig(appToken, environment, legacy) {
    this.appToken = appToken;
    this.environment = environment;
    this.sendInBackground = null;
    this.logLevel = null;
    this.defaultTracker = null;
    this.adjustAttributionChangedSubscriberCallbackId = null;
    this.adjustAttributionChangedSubscriberCallback = null;
    this.adjustAttributionReadSubscriberCallbackId = null;
    this.adjustAttributionReadSubscriberCallback = null;
    this.adjustIdentifierReadSubscriberCallbackId = null;
    this.adjustIdentifierReadSubscriberCallback = null;
    this.adjustIdentifierChangedSubscriberCallbackId = null;
    this.adjustIdentifierChangedSubscriberCallback = null;
    this.openDeferredDeeplink = null;
    this.eventDeduplicationListLimit = null;
    this.externalDeviceId = null;
    this.playStoreKidsAppEnabled = null;
    this.coppaCompliantEnabled = null;
    this.preinstallConfig = null;
    this.urlStrategy = null;
    this.dataResidency = null;
    this.needsCost = null;
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

AdjustConfig.prototype.setPreinstallConfig = function(preinstallConf) {
    this.preinstallConfig = preinstallConf;
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
}

AdjustConfig.prototype.setEventDeduplicationListLimit = function(limit) {
    this.eventDeduplicationListLimit = limit;
}

AdjustConfig.prototype.setExternalDeviceId = function(externalDevId){
    this.externalDeviceId = externalDevId;
}

AdjustConfig.prototype.setPlayStoreKidsAppEnabled = function(isEnabled) {
    this.playStoreKidsAppEnabled = isEnabled;
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
