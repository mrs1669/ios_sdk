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
            console.log('TestLibraryBridge TestOption only method should be teardown.');
            return;
        }
    }

    if (command.className == 'AdjustV4') {
        console.log('TestLibraryBridge AdjustV4 is not supported.');
        return;
    }
    // reflection based technique to call functions with the same name as the command function
    localAdjustCommandExecutor[command.functionName](command.params);
},

startTestSession: function () {
    console.log('TestLibraryBridge startTestSession');
    console.log('TestLibraryBridge startTestSession callHandler');
    localAdjustCommandExecutor = new AdjustCommandExecutor(localBaseUrl, localGdprUrl);
    // pass the sdk version to native side
    const message = {
    action:'adjustTLB_startTestSession',
    data: 'web-bridge5.0.0@ios5.0.0'
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

teardownReturnExtraPath: function(extraPath) {
    this.extraPath = extraPath;
    // TODO - pending implementatio
    // Adjust.instance().teardown;
},

didChangeWithAdjustAttribution: function(attributionValue) {
    console.log('TestLibraryBridge didChangeWithAdjustAttribution');
},

didReadWithAdjustAttribution: function(attributionValue) {
    console.log('TestLibraryBridge didReadWithAdjustAttribution');
},
    
};

var AdjustCommandExecutor = function(baseUrl, gdprUrl) {
    this.baseUrl = baseUrl;
    this.gdprUrl = gdprUrl;
    this.extraPath = null;
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

addInfoToSend = function(key, value) {
    const message = {
    action:'adjustTLB_addInfoToSend',
    data: {key: key, value: value}
    };
    window.webkit.messageHandlers.adjustTest.postMessage(message);
};

sendInfoToServer = function(extraPath) {
    const message = {
    action:'adjustTLB_sendInfoToServer',
    data: extraPath
    };
    window.webkit.messageHandlers.adjustTest.postMessage(message);
};

AdjustCommandExecutor.prototype.start = function(params) {
    console.log("AdjustCommandExecutor.prototype.start");
    var adjustConfig = new AdjustConfig();

    var appToken = getFirstParameterValue(params, "appToken");
    var environment = getFirstParameterValue(params, "environment");
    adjustConfig = new AdjustConfig(appToken, environment);

    if ('defaultTracker' in params) {
        var defaultTracker = getFirstParameterValue(params, 'defaultTracker');
        adjustConfig.setDefaultTracker(defaultTracker);
    }

    if ('sendInBackground' in params) {
        var sendInBackground = getFirstParameterValue(params, 'sendInBackground');
        if (sendInBackground === 'true') {
            adjustConfig.allowSendingFromBackground();
        }
    }

    if ('configureEventDeduplication' in params) {
        var configureEventDeduplication = getFirstParameterValue(params, 'configureEventDeduplication');
        adjustConfig.setEventDeduplicationListLimit(configureEventDeduplication);
    }

    if ('customEndpointUrl' in params || 'customEndpointPublicKeyHash' in params || 'testServerBaseUrlEndpointUrl' in params) {
        console.log("TORMV endpoint");

        var customEndpointPublicKeyHash = getFirstParameterValue(params, 'customEndpointPublicKeyHash');

        var customEndpointUrl = null;
        if ('testServerBaseUrlEndpointUrl' in params) {
            customEndpointUrl = baseUrl;
        } else {
            customEndpointUrl = getFirstParameterValue(params, 'customEndpointUrl');
        }

        adjustConfig.setCustomEndpoint(customEndpointUrl, customEndpointPublicKeyHash);
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
        var shouldOpenDeeplinkS = getFirstParameterValue(params, 'deferredDeeplinkCallback');
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

    Adjust.instance().initSDK(adjustConfig);
};

AdjustCommandExecutor.prototype.trackEvent = function(params) {

    var eventToken = getFirstParameterValue(params, 'eventToken');
    var adjustEvent = new AdjustEvent(eventToken);

    if ('currencyAndRevenue' in params) {
        var revenueParams = getValueFromKey(params, 'currencyAndRevenue');
        var currency = revenueParams[0];
        var revenue = parseFloat(revenueParams[1]);
        adjustEvent.setRevenue(revenue, currency);
    }

    if ('callbackParams' in params) {
        var callbackParams = getValueFromKey(params, "callbackParams");
        for (var i = 0; i < callbackParams.length; i = i + 2) {
            var key = callbackParams[i];
            var value = callbackParams[i + 1];
            adjustEvent.addCallbackParameter(key, value);
        }
    }

    if ('partnerParams' in params) {
        var partnerParams = getValueFromKey(params, "partnerParams");
        for (var i = 0; i < partnerParams.length; i = i + 2) {
            var key = partnerParams[i];
            var value = partnerParams[i + 1];
            adjustEvent.addPartnerParameter(key, value);
        }
    }

    if ('deduplicationId' in params) {
        var deduplicationId = getFirstParameterValue(params, 'deduplicationId');
        adjustEvent.setDeduplicationId(deduplicationId);
    }

    Adjust.instance().trackEvent(adjustEvent);

};

AdjustCommandExecutor.prototype.stop = function() {
    Adjust.instance().inactivateSdk();
};

AdjustCommandExecutor.prototype.restart = function() {
    Adjust.instance().reactivateSdk();
};

AdjustCommandExecutor.prototype.setOfflineMode = function(params) {
    var enabled = getFirstParameterValue(params, "enabled") == 'true';
    if (enabled) {
        Adjust.instance().switchToOfflineMode();
    } else {
        Adjust.instance().switchBackToOnlineMode();
    }
};

AdjustCommandExecutor.prototype.addGlobalCallbackParameter = function(params) {
    var list = getValueFromKey(params, "keyValuePairs");
    for (var i = 0; i < list.length; i += 2) {
        var key = list[i];
        var value = list[i + 1];
        Adjust.instance().addGlobalCallbackParameter(key, value);
    }
};

AdjustCommandExecutor.prototype.addGlobalPartnerParameter = function(params) {
    var list = getValueFromKey(params, "keyValuePairs");
    for (var i = 0; i < list.length; i += 2) {
        var key = list[i];
        var value = list[i + 1];
        Adjust.instance().addGlobalPartnerParameter(key, value);
    }
};

AdjustCommandExecutor.prototype.removeGlobalCallbackParameter = function(params) {
    if ('key' in params) {
        var list = getValueFromKey(params, 'key');
        for (var i = 0; i < list.length; i += 1) {
            Adjust.instance().removeGlobalCallbackParameter(list[i]);
        }
    }
};

AdjustCommandExecutor.prototype.removeGlobalPartnerParameter = function(params) {
    if ('key' in params) {
        var list = getValueFromKey(params, 'key');
        for (var i = 0; i < list.length; i += 1) {
            Adjust.instance().removeGlobalPartnerParameter(list[i]);
        }
    }
};

AdjustCommandExecutor.prototype.clearGlobalCallbackParameters = function(params) {
    Adjust.instance().clearAllGlobalCallbackParameters();
};

AdjustCommandExecutor.prototype.clearGlobalPartnerParameters = function(params) {
    Adjust.instance().clearAllGlobalPartnerParameters();
};

AdjustCommandExecutor.prototype.setPushToken = function(params) {
    var token = getFirstParameterValue(params, 'pushToken');
    Adjust.instance().trackPushToken(token);
};

AdjustCommandExecutor.prototype.openDeeplink = function(params) {
    var deeplink = getFirstParameterValue(params, "deeplink");
    Adjust.instance().trackLaunchedDeeplink(deeplink);
};

AdjustCommandExecutor.prototype.gdprForgetMe = function(params) {
    Adjust.instance().gdprForgetMe();
};

AdjustCommandExecutor.prototype.trackAdRevenue = function(params) {

    var source = getFirstParameterValue(params, "adRevenueSource");

    var adjustAdRevenue = new AdjustAdRevenue(source);

    if ('currencyAndRevenue' in params) {
        var revenueParams = getValueFromKey(params, 'currencyAndRevenue');
        var currency = revenueParams[0];
        var revenue = parseFloat(revenueParams[1]);
        adjustAdRevenue.setAdRevenue(revenue, currency);
    }

    var adImpressionsCount = getFirstParameterValue(params, 'adImpressionsCount');
    adjustAdRevenue.setAdImpressionsCount(adImpressionsCount);

    var adRevenueNetwork = getFirstParameterValue(params, 'adRevenueNetwork');
    adjustAdRevenue.setAdRevenueNetwork(adRevenueNetwork);

    var adRevenueUnit = getFirstParameterValue(params, 'adRevenueUnit');
    adjustAdRevenue.setAdRevenueUnit(adRevenueUnit);

    var adRevenuePlacement = getFirstParameterValue(params, 'adRevenuePlacement');
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

    Adjust.instance().trackAdRevenue(adjustAdRevenue);

};

AdjustCommandExecutor.prototype.disableThirdPartySharing = function(params) {
    Adjust.instance().disableThirdPartySharing();
};

AdjustCommandExecutor.prototype.resume = function(params) {
    Adjust.instance().appWentToTheForegroundManualCall();
};

AdjustCommandExecutor.prototype.pause = function(params) {
    Adjust.instance().appWentToTheBackgroundManualCall();
};

AdjustCommandExecutor.prototype.thirdPartySharing = function(params) {
    var isEnabledS = getFirstParameterValue(params, 'isEnabled');

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
            adjustThirdPartySharing.addPartnerSharingSettings(partnerName, key, value);
        }
    }

    Adjust.instance().trackThirdPartySharing(adjustThirdPartySharing);
};

AdjustCommandExecutor.prototype.measurementConsent = function(params) {
    var consentMeasurement = getFirstParameterValue(params, 'isEnabled') == 'true';
//    Adjust.instance().trackMeasurementConsent(consentMeasurement);
};

// Util
function getValueFromKey(params, key) {
    if (key in params) {
        return params[key];
    }

    return null;
};

function getFirstParameterValue(params, key) {
    if (key in params) {
        var param = params[key];

        if(param != null && param.length >= 1) {
            return param[0];
        }
    }

    return null;
};

module.exports = TestLibraryBridge;



