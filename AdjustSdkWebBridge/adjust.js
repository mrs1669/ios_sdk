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
//    this.callbacksMap = new Map();
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


