// simulator
var localBaseUrl = 'http://127.0.0.1:8080';
var localGdprUrl = 'http://127.0.0.1:8080';
// device
// var localBaseUrl = 'http://192.168.86.65:8080';
// var localGdprUrl = 'http://192.168.86.65:8080';

// local reference of the command executor
// originally it was this.adjustCommandExecutor of TestLibraryBridge var
// but for some reason, "this" on "startTestSession" was different in "adjustCommandExecutor"
var localAdjustCommandExecutor;

var TestLibraryBridge = {
adjustCommandExecutor: function(commandRawJson) {
    console.log('TestLibraryBridge adjustCommandExecutor');
    const command = JSON.parse(commandRawJson);
    console.log('className: ' + command.className);
    console.log('functionName: ' + command.functionName);
    console.log('params: ' + JSON.stringify(command.params));

    if (command.className == 'TestOptions') {
        if (command.functionName != "teardown") {
            console.log('TestLibraryBridge TestOption only method should be teardown');
            return;
        }

        //this.testOptions(command.params);

        //return;
    }
    // reflection based technique to call functions with the same name as the command function
    localAdjustCommandExecutor[command.functionName](command.params);
},

teardownReturnExtraPath: function(extraPath) {
    this.extraPath = extraPath;
    // TODO - pending implementatio
    // Adjust.teardown;
},

startTestSession: function () {
    console.log('TestLibraryBridge startTestSession');
    console.log('TestLibraryBridge startTestSession callHandler');
    localAdjustCommandExecutor = new AdjustCommandExecutor(localBaseUrl, localGdprUrl);
    // pass the sdk version to native side
    const message = {
    action:'adjustTLB_startTestSession',
    data: 'ios5.0.0'
    };
    window.webkit.messageHandlers.adjustTest.postMessage(message);
},

addTestDirectory: function(directoryName) {
    const message = {
    action:'adjustTLB_addTestDirectory',
    data: directoryName
    };
    window.webkit.messageHandlers.adjustTest.postMessage(message);
},

addTest: function(testName) {
    const message = {
    action:'adjustTLB_addTest',
    data: testName
    };
    window.webkit.messageHandlers.adjustTest.postMessage(message);
},
};

var AdjustCommandExecutor = function(baseUrl, gdprUrl) {
    this.baseUrl = baseUrl;
    this.gdprUrl = gdprUrl;
    this.extraPath = null;
    this.savedEvents = {};
    this.savedConfigs = {};
    this.savedCommands = [];
    this.nextToSendCounter = 0;
};

AdjustCommandExecutor.prototype.teardown = function(params) {
    console.log('TestLibraryBridge teardown');
    console.log('params: ' + JSON.stringify(params));

    for (key in params) {
        for (var i = 0; i < params[key].length; i += 1) {
            value = params[key][i];
            // send to test options to native side
            const message = {
            action:'adjustTLB_addToTestOptionsSet',
            data: {key: key, value: value}
            };
            window.webkit.messageHandlers.adjustTest.postMessage(message);
        }
    }

    const message = {
    action:'adjustTLB_teardownAndApplyAddedTestOptionsSet'
    };
    window.webkit.messageHandlers.adjustTest.postMessage(message);
};

AdjustCommandExecutor.prototype.config = function(params) {
    var configNumber = 0;
    if ('configName' in params) {
        var configName = getFirstValue(params, 'configName');
        configNumber = parseInt(configName.substr(configName.length - 1));
    }

    var adjustConfig;
    if (configNumber in this.savedConfigs) {
        adjustConfig = this.savedConfigs[configNumber];
    } else {
        var environment = getFirstValue(params, 'environment');
        var appToken = getFirstValue(params, 'appToken');

        adjustConfig = new AdjustConfig(appToken, environment);
        adjustConfig.setLogLevel(AdjustConfig.LogLevelVerbose);

        this.savedConfigs[configNumber] = adjustConfig;
    }

    if ('logLevel' in params) {
        var logLevelS = getFirstValue(params, 'logLevel');
        var logLevel = null;
        switch (logLevelS) {
            case "verbose":
                logLevel = AdjustConfig.LogLevelVerbose;
                break;
            case "debug":
                logLevel = AdjustConfig.LogLevelDebug;
                break;
            case "info":
                logLevel = AdjustConfig.LogLevelInfo;
                break;
            case "warn":
                logLevel = AdjustConfig.LogLevelWarn;
                break;
            case "error":
                logLevel = AdjustConfig.LogLevelError;
                break;
            case "assert":
                logLevel = AdjustConfig.LogLevelAssert;
                break;
            case "suppress":
                logLevel = AdjustConfig.LogLevelSuppress;
                break;
        }

        adjustConfig.setLogLevel(logLevel);
    }

    if ('sdkPrefix' in params) {
        var sdkPrefix = getFirstValue(params, 'sdkPrefix');
        adjustConfig.setSdkPrefix(sdkPrefix);
    }

    if ('defaultTracker' in params) {
        var defaultTracker = getFirstValue(params, 'defaultTracker');
        adjustConfig.setDefaultTracker(defaultTracker);
    }

    if ('externalDeviceId' in params) {
        var externalDeviceId = getFirstValue(params, 'externalDeviceId');
        adjustConfig.setExternalDeviceId(externalDeviceId);
    }

    if ('appSecret' in params) {
        var appSecretArray = getValueFromKey(params, 'appSecret');
        var secretId = appSecretArray[0].toString();
        var info1    = appSecretArray[1].toString();
        var info2    = appSecretArray[2].toString();
        var info3    = appSecretArray[3].toString();
        var info4    = appSecretArray[4].toString();
        adjustConfig.setAppSecret(secretId, info1, info2, info3, info4);
    }

    if ('delayStart' in params) {
        var delayStartS = getFirstValue(params, 'delayStart');
        var delayStart = parseFloat(delayStartS);
        adjustConfig.setDelayStart(delayStart);
    }

    if ('deviceKnown' in params) {
        var deviceKnownS = getFirstValue(params, 'deviceKnown');
        var deviceKnown = deviceKnownS == 'true';
        adjustConfig.setIsDeviceKnown(deviceKnown);
    }

    if ('needsCost' in params) {
        var needsCostS = getFirstValue(params, 'needsCost');
        var needsCost = needsCostS == 'true';
        adjustConfig.setNeedsCost(needsCost);
    }

    if ('allowiAdInfoReading' in params) {
        var allowiAdInfoReadingS = getFirstValue(params, 'allowiAdInfoReading');
        var allowiAdInfoReading = allowiAdInfoReadingS == 'true';
        adjustConfig.setAllowiAdInfoReading(allowiAdInfoReading);
    }

    if ('allowAdServicesInfoReading' in params) {
        var allowAdServicesInfoReadingS = getFirstValue(params, 'allowAdServicesInfoReading');
        var allowAdServicesInfoReading = allowAdServicesInfoReadingS == 'true';
        adjustConfig.setAllowAdServicesInfoReading(allowAdServicesInfoReading);
    }

    if ('allowIdfaReading' in params) {
        var allowIdfaReadingS = getFirstValue(params, 'allowIdfaReading');
        var allowIdfaReading = allowIdfaReadingS == 'true';
        adjustConfig.setAllowIdfaReading(allowIdfaReading);
    }

//    if ('allowSkAdNetworkHandling' in params) {
//        var allowSkAdNetworkHandlingS = getFirstValue(params, 'allowSkAdNetworkHandling');
//        var allowSkAdNetworkHandling = allowSkAdNetworkHandlingS == 'true';
//        if (allowSkAdNetworkHandling == false) {
//            adjustConfig.deactivateSkAdNetworkHandling();
//        }
//    }

    if ('eventBufferingEnabled' in params) {
        var eventBufferingEnabledS = getFirstValue(params, 'eventBufferingEnabled');
        var eventBufferingEnabled = eventBufferingEnabledS == 'true';
        adjustConfig.setEventBufferingEnabled(eventBufferingEnabled);
    }

    if ('coppaCompliant' in params) {
        var coppaCompliantEnabledS = getFirstValue(params, 'coppaCompliant');
        var coppaCompliantEnabled = coppaCompliantEnabledS == 'true';
        adjustConfig.setCoppaCompliantEnabled(coppaCompliantEnabled);
    }

    if ('sendInBackground' in params) {
        var sendInBackgroundS = getFirstValue(params, 'sendInBackground');
        var sendInBackground = sendInBackgroundS == 'true';
        adjustConfig.setSendInBackground(sendInBackground);
    }

    if ('userAgent' in params) {
        var userAgent = getFirstValue(params, 'userAgent');
        adjustConfig.setUserAgent(userAgent);
    }

    if ('attributionCallbackSendAll' in params) {
        console.log('AdjustCommandExecutor.prototype.config attributionCallbackSendAll');
        var extraPath = this.extraPath;
        adjustConfig.setAttributionCallback(
                                            function(attribution) {
                                                console.log('attributionCallback: ' + JSON.stringify(attribution));
                                                addInfoToSend('trackerToken', attribution.trackerToken);
                                                addInfoToSend('trackerName', attribution.trackerName);
                                                addInfoToSend('network', attribution.network);
                                                addInfoToSend('campaign', attribution.campaign);
                                                addInfoToSend('adgroup', attribution.adgroup);
                                                addInfoToSend('creative', attribution.creative);
                                                addInfoToSend('clickLabel', attribution.click_label);
                                                addInfoToSend('adid', attribution.adid);
                                                addInfoToSend('costType', attribution.costType);
                                                addInfoToSend('costAmount', attribution.costAmount);
                                                addInfoToSend('costCurrency', attribution.costCurrency);
                                                sendInfoToServer(extraPath);
                                            }
                                            );
    }

    if ('sessionCallbackSendSuccess' in params) {
        console.log('AdjustCommandExecutor.prototype.config sessionCallbackSendSuccess');
        var extraPath = this.extraPath;
        adjustConfig.setSessionSuccessCallback(
                                               function(sessionSuccessResponseData) {
                                                   console.log('sessionSuccessCallback: ' + JSON.stringify(sessionSuccessResponseData));
                                                   addInfoToSend('message', sessionSuccessResponseData.message);
                                                   addInfoToSend('timestamp', sessionSuccessResponseData.timestamp);
                                                   addInfoToSend('adid', sessionSuccessResponseData.adid);
                                                   addInfoToSend('jsonResponse', sessionSuccessResponseData.jsonResponse);
                                                   sendInfoToServer(extraPath);
                                                 }
                                               );
    }

    if ('sessionCallbackSendFailure' in params) {
        console.log('AdjustCommandExecutor.prototype.config sessionCallbackSendFailure');
        var extraPath = this.extraPath;
        adjustConfig.setSessionFailureCallback(
                                               function(sessionFailureResponseData) {
                                                   console.log('sessionFailureCallback: ' + JSON.stringify(sessionFailureResponseData));
                                                   addInfoToSend('message', sessionFailureResponseData.message);
                                                   addInfoToSend('timestamp', sessionFailureResponseData.timestamp);
                                                   addInfoToSend('adid', sessionFailureResponseData.adid);
                                                   addInfoToSend('willRetry', sessionFailureResponseData.willRetry ? 'true' : 'false');
                                                   addInfoToSend('jsonResponse', sessionFailureResponseData.jsonResponse);
                                                   sendInfoToServer(extraPath);
                                               }
                                               );
    }

    if ('eventCallbackSendSuccess' in params) {
        console.log('AdjustCommandExecutor.prototype.config eventCallbackSendSuccess');
        var extraPath = this.extraPath;
        adjustConfig.setEventSuccessCallback(
                                             function(eventSuccessResponseData) {
                                                 console.log('eventSuccessCallback: ' + JSON.stringify(eventSuccessResponseData));
                                                 addInfoToSend('message', eventSuccessResponseData.message);
                                                 addInfoToSend('timestamp', eventSuccessResponseData.timestamp);
                                                 addInfoToSend('adid', eventSuccessResponseData.adid);
                                                 addInfoToSend('eventToken', eventSuccessResponseData.eventToken);
                                                 addInfoToSend('callbackId', eventSuccessResponseData.callbackId);
                                                 addInfoToSend('jsonResponse', eventSuccessResponseData.jsonResponse);
                                                 sendInfoToServer(extraPath);
                                             }
                                             );
    }

    if ('eventCallbackSendFailure' in params) {
        console.log('AdjustCommandExecutor.prototype.config eventCallbackSendFailure');
        var extraPath = this.extraPath;
        adjustConfig.setEventFailureCallback(
                                             function(eventFailureResponseData) {
                                                 console.log('eventFailureCallback: ' + JSON.stringify(eventFailureResponseData));
                                                 addInfoToSend('message', eventFailureResponseData.message);
                                                 addInfoToSend('timestamp', eventFailureResponseData.timestamp);
                                                 addInfoToSend('adid', eventFailureResponseData.adid);
                                                 addInfoToSend('eventToken', eventFailureResponseData.eventToken);
                                                 addInfoToSend('callbackId', eventFailureResponseData.callbackId);
                                                 addInfoToSend('willRetry', eventFailureResponseData.willRetry ? 'true' : 'false');
                                                 addInfoToSend('jsonResponse', eventFailureResponseData.jsonResponse);
                                                 sendInfoToServer(extraPath);
                                            }
                                             );
    }

    if ('deferredDeeplinkCallback' in params) {
        console.log('AdjustCommandExecutor.prototype.config deferredDeeplinkCallback');
        var shouldOpenDeeplinkS = getFirstValue(params, 'deferredDeeplinkCallback');
        if (shouldOpenDeeplinkS === 'true') {
            adjustConfig.setOpenDeferredDeeplink(true);
        }
        if (shouldOpenDeeplinkS === 'false') {
            adjustConfig.setOpenDeferredDeeplink(false);
        }
        var extraPath = this.extraPath;
        adjustConfig.setDeferredDeeplinkCallback(
                                                 function(deeplink) {
                                                     console.log('deferredDeeplinkCallback: ' + JSON.stringify(deeplink));
                                                     addInfoToSend('deeplink', deeplink);
                                                     sendInfoToServer(extraPath);
                                                   }
                                                 );
    }
};

var addInfoToSend = function(key, value) {
    const message = {
    action:'adjustTLB_addInfoToSend',
    data: {key: key, value: value}
    };
    window.webkit.messageHandlers.adjustTest.postMessage(message);
};

var sendInfoToServer = function(extraPath) {
    const message = {
    action:'adjustTLB_sendInfoToServer',
    data: extraPath
    };
    window.webkit.messageHandlers.adjustTest.postMessage(message);
};

AdjustCommandExecutor.prototype.start = function(params) {
    this.config(params);
    var configNumber = 0;
    if ('configName' in params) {
        var configName = getFirstValue(params, 'configName');
        configNumber = parseInt(configName.substr(configName.length - 1));
    }

    var adjustConfig = this.savedConfigs[configNumber];
    Adjust.initSDK(adjustConfig);

    delete this.savedConfigs[0];
};

AdjustCommandExecutor.prototype.event = function(params) {
    var eventNumber = 0;
    if ('eventName' in params) {
        var eventName = getFirstValue(params, 'eventName');
        eventNumber = parseInt(eventName.substr(eventName.length - 1))
    }

    var adjustEvent;
    if (eventNumber in this.savedEvents) {
        adjustEvent = this.savedEvents[eventNumber];
    } else {
        var eventToken = getFirstValue(params, 'eventToken');
        adjustEvent = new AdjustEvent(eventToken);
        this.savedEvents[eventNumber] = adjustEvent;
    }

    if ('revenue' in params) {
        var revenueParams = getValueFromKey(params, 'revenue');
        var currency = revenueParams[0];
        var revenue = parseFloat(revenueParams[1]);
        adjustEvent.setRevenue(revenue, currency);
    }

    if ('callbackParams' in params) {
        var callbackParams = getValueFromKey(params, 'callbackParams');
        for (var i = 0; i < callbackParams.length; i = i + 2) {
            var key = callbackParams[i];
            var value = callbackParams[i + 1];
            adjustEvent.addCallbackParameter(key, value);
        }
    }

    if ('partnerParams' in params) {
        var partnerParams = getValueFromKey(params, 'partnerParams');
        for (var i = 0; i < partnerParams.length; i = i + 2) {
            var key = partnerParams[i];
            var value = partnerParams[i + 1];
            adjustEvent.addPartnerParameter(key, value);
        }
    }

//    if ('orderId' in params) {
//        var orderId = getFirstValue(params, 'orderId');
//        adjustEvent.setTransactionId(orderId);
//    }

    if ('callbackId' in params) {
        var callbackId = getFirstValue(params, 'callbackId');
        adjustEvent.setCallbackId(callbackId);
    }
};

AdjustCommandExecutor.prototype.trackEvent = function(params) {
    this.event(params);
    var eventNumber = 0;
    if ('eventName' in params) {
        var eventName = getFirstValue(params, 'eventName');
        eventNumber = parseInt(eventName.substr(eventName.length - 1))
    }

    var adjustEvent = this.savedEvents[eventNumber];
    Adjust.trackEvent(adjustEvent);

    delete this.savedEvents[0];
};

AdjustCommandExecutor.prototype.pause = function(params) {
    Adjust.inactiveSDK();
};

AdjustCommandExecutor.prototype.resume = function(params) {
    Adjust.reactivateSDK();
};

AdjustCommandExecutor.prototype.setEnabled = function(params) {
    var enabled = getFirstValue(params, 'enabled') == 'true';
    Adjust.switchToOnlineMode(enabled);
};

AdjustCommandExecutor.prototype.setOfflineMode = function(params) {
    var enabled = getFirstValue(params, 'enabled') == 'true';
    Adjust.switchToOfflineMode(enabled);
};

AdjustCommandExecutor.prototype.sendFirstPackages = function(params) {
    Adjust.sendFirstPackages();
};

AdjustCommandExecutor.prototype.gdprForgetMe = function(params) {
    Adjust.gdprForgetMe();
};

AdjustCommandExecutor.prototype.addSessionCallbackParameter = function(params) {
    var list = getValueFromKey(params, 'KeyValue');

    for (var i = 0; i < list.length; i = i+2){
        var key = list[i];
        var value = list[i+1];
        Adjust.addSessionCallbackParameter(key, value);
    }
};

AdjustCommandExecutor.prototype.addSessionPartnerParameter = function(params) {
    var list = getValueFromKey(params, 'KeyValue');

    for (var i = 0; i < list.length; i = i+2){
        var key = list[i];
        var value = list[i+1];
        Adjust.addSessionPartnerParameter(key, value);
    }
};

AdjustCommandExecutor.prototype.removeSessionCallbackParameter = function(params) {
    var list = getValueFromKey(params, 'key');

    for (var i = 0; i < list.length; i++) {
        var key = list[i];
        Adjust.removeSessionCallbackParameter(key);
    }
};

AdjustCommandExecutor.prototype.removeSessionPartnerParameter = function(params) {
    var list = getValueFromKey(params, 'key');

    for (var i = 0; i < list.length; i++) {
        var key = list[i];
        Adjust.removeSessionPartnerParameter(key);
    }
};

AdjustCommandExecutor.prototype.resetSessionCallbackParameters = function(params) {
    Adjust.resetSessionCallbackParameters();
};

AdjustCommandExecutor.prototype.resetSessionPartnerParameters = function(params) {
    Adjust.resetSessionPartnerParameters();
};

AdjustCommandExecutor.prototype.setPushToken = function(params) {
    var token = getFirstValue(params, 'pushToken');
    Adjust.trackPushToken(token);
};

AdjustCommandExecutor.prototype.openDeeplink = function(params) {
    var deeplink = getFirstValue(params, 'deeplink');
    Adjust.trackDeeplink(deeplink);
};

AdjustCommandExecutor.prototype.trackAdRevenue = function(params) {

    var source = getFirstValue(params, "adRevenueSource");

        var adjustAdRevenue = new AdjustAdRevenue(source);

        if ('currencyAndRevenue' in params) {
            var revenueParams = getValueFromKey(params, 'currencyAndRevenue');
            var currency = revenueParams[0];
            var revenue = parseFloat(revenueParams[1]);
            adjustAdRevenue.setAdRevenue(revenue, currency);
        }

        var adImpressionsCount = getFirstValue(params, 'adImpressionsCount');
        adjustAdRevenue.setAdImpressionsCount(adImpressionsCount);

        var adRevenueNetwork = getFirstValue(params, 'adRevenueNetwork');
        adjustAdRevenue.setAdRevenueNetwork(adRevenueNetwork);

        var adRevenueUnit = getFirstValue(params, 'adRevenueUnit');
        adjustAdRevenue.setAdRevenueUnit(adRevenueUnit);

        var adRevenuePlacement = getFirstValue(params, 'adRevenuePlacement');
        adjustAdRevenue.setAdRevenuePlacement(adRevenuePlacement);

        if ('callbackParams' in params) {
            var callbackParams = getValueFromKey(params, "callbackParams");
            for (var i = 0; i < callbackParams.length; i = i + 2) {
                var key = callbackParams[i];
                var value = callbackParams[i + 1];
                adjustAdRevenue.addCallbackParameter(key, value);
            }
        }

        if ('partnerParams' in params) {
            var partnerParams = getValueFromKey(params, "partnerParams");
            for (var i = 0; i < partnerParams.length; i = i + 2) {
                var key = partnerParams[i];
                var value = partnerParams[i + 1];
                adjustAdRevenue.addPartnerParameter(key, value);
            }
        }

    Adjust.trackAdRevenue(adjustAdRevenue);

};

AdjustCommandExecutor.prototype.disableThirdPartySharing = function(params) {
    Adjust.disableThirdPartySharing();
};

AdjustCommandExecutor.prototype.thirdPartySharing = function(params) {
    var isEnabledS = getFirstValue(params, 'isEnabled');

    var isEnabled = null;
    if (isEnabledS == 'true') {
        isEnabled = true;
    }
    if (isEnabledS == 'false') {
        isEnabled = false;
    }

    var adjustThirdPartySharing = new AdjustThirdPartySharing(isEnabled);
    if ('granularOptions' in params) {
        var granularOptions = getValueFromKey(params, 'granularOptions');
        for (var i = 0; i < granularOptions.length; i = i + 3) {
            var partnerName = granularOptions[i];
            var key = granularOptions[i + 1];
            var value = granularOptions[i + 2];
            adjustThirdPartySharing.addGranularOption(partnerName, key, value);
        }
    }
    if ('partnerSharingSettings' in params) {
        var partnerSharingSettings = getValueFromKey(params, 'partnerSharingSettings');
        for (var i = 0; i < partnerSharingSettings.length; i = i + 3) {
            var partnerName = partnerSharingSettings[i];
            var key = partnerSharingSettings[i + 1];
            var value = partnerSharingSettings[i + 2];
            adjustThirdPartySharing.addPartnerSharingSetting(partnerName, key, value);
        }
    }

    Adjust.trackThirdPartySharing(adjustThirdPartySharing);
};

AdjustCommandExecutor.prototype.measurementConsent = function(params) {
    var consentMeasurement = getFirstValue(params, 'isEnabled') == 'true';
    Adjust.trackMeasurementConsent(consentMeasurement);
};

// Util
function getValueFromKey(params, key) {
    if (key in params) {
        return params[key];
    }

    return null;
}

function getFirstValue(params, key) {
    if (key in params) {
        var param = params[key];

        if(param != null && param.length >= 1) {
            return param[0];
        }
    }

    return null;
}

module.exports = TestLibraryBridge;

