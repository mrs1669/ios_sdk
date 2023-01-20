var Adjust = {

initSDK: function (adjustConfig) {
    const message = {
    action:'adjust_initSdk',
    data: adjustConfig,
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

trackEvent: function (adjustEvent) {
    const message = {
    action:'adjust_trackEvent',
    data: adjustEvent
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

trackAdRevenue: function (adjustRevenue) {
    const message = {
    action:'adjust_trackAdRevenue',
    data: adjustRevenue
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

trackDeeplink: function(url) {
    const message = {
    action:'adjust_trackDeeplink',
    data: url
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

trackPushToken: function(token) {
    const message = {
    action:'adjust_trackPushToken',
    data: token
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

switchToOfflineMode: function() {
    const message = {
    action:'adjust_switchToOfflineMode',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

switchToOnlineMode: function() {
    const message = {
    action:'adjust_switchToOnlineMode',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

inactiveSDK: function() {
    const message = {
    action:'adjust_inactivateSdk',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

reactivateSDK: function() {
    const message = {
    action:'adjust_reactivateSdk',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

addGlobalCallbackParameter: function(key, value) {
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
},

removeGlobalCallbackParameter: function(key) {
    if (typeof key !== 'string') {
        console.log('Passed key is not of string type');
        return;
    }
    const message = {
    action:'adjust_removeGlobalCallbackParameterByKey',
    key: key,
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

clearAllGlobalCallbackParameters: function() {
    const message = {
    action:'adjust_clearAllGlobalCallbackParameters',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

addGlobalPartnerParameter: function(key, value) {
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
},

removeGlobalPartnerParameter: function(key) {
    if (typeof key !== 'string') {
        console.log('Passed key is not of string type');
        return;
    }
    const message = {
    action:'adjust_removeGlobalPartnerParameterByKey',
    key: key,
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

clearAllGlobalPartnerParameters: function() {
    const message = {
    action:'adjust_clearAllGlobalPartnerParameters',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

gdprForgetMe: function() {
    const message = {
    action:'adjust_gdprForgetMe',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

trackThirdPartySharing: function(adjustThirdPartySharing) {
    const message = {
    action:'adjust_trackThirdPartySharing',
    data: adjustThirdPartySharing
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

teardown: function(adjustConfig) {
    const message = {
    action:'adjust_teardown',
    data: adjustConfig
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

appWentToTheBackgroundManualCall: function() {
    const message = {
    action:'adjust_appWentToTheBackgroundManualCall',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

appWentToTheForegroundManualCall: function() {
    const message = {
    action:'adjust_appWentToTheForegroundManualCall',
    };
    window.webkit.messageHandlers.adjust.postMessage(message);
},

}

