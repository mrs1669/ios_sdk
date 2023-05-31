const TestLibrary = {
_postMessage(methodName, parameters = {}) {
    if (! TestLibrary._testLibraryMessageHandler) {
        function canSend(okCheck, errReason) {
            if (! okCheck) { if (TestLibrary._errSubscriber) {
                TestLibrary._errSubscriber("Cannot send message to native sdk ".concat(errReason));
            }}
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
        canSend(typeof window.webkit.messageHandlers.testLibrary.postMessage === "function",
                "when 'window.webkit.messageHandlers.testLibrary.postMessage' is not a function");

        if (! canSendSendToNative) { return; }

        TestLibrary._testLibraryMessageHandler = window.webkit.messageHandlers.testLibrary;
    }

    TestLibrary._testLibraryMessageHandler.postMessage({
        _methodName: methodName,
        _parameters: JSON.stringify(parameters)
    });
},
addTest: function(testName) {
    TestLibrary._postMessage("addTest", {_testName: testName, _testNameType: typeof testName});
},
addTestDirectory: function(directoryName) {
    TestLibrary._postMessage("addTestDirectory", {
        _directoryName: directoryName, _directoryNameType: typeof directoryName});
},
addInfoToSend: function(key, value) {
    TestLibrary._postMessage("addInfoToSend", {
        _key: key,
        _keyType: typeof key,
        _value: value,
        _valueType: typeof value
    });
},
sendInfoToServer: function() {
    TestLibrary._postMessage("sendInfoToServer");
},
startTestSession: function(sdkVersion) {
    TestLibrary._adjustCommandExecutor = new AdjustCommandExecutor();

    TestLibrary._postMessage("startTestSession", {
        _sdkVersion: sdkVersion, _sdkVersionType: typeof sdkVersion});
},
_sdk_errSubscriber: function(errMessage) {
    TestLibrary._postMessage("jsFail", {
        _message: "sdk errSubscriber message",
        _errMessage: errMessage,
        _errMessageType: typeof errMessage
    });
},
_adjustDefaultInstance: function () {
    return Adjust.instance("", TestLibrary._sdk_errSubscriber);
},
_getFirstParam: function(params, key) {
    if (key in params && params[key] && params[key].length && params[key].length >= 1) {
        return params[key][0];
    }
    return undefined;
},
_firstParam: function(params, key, callback) {
    const value = TestLibrary._getFirstParam(params, key);
    if (value) { callback(value); }
},
_firstTwoParam: function(params, key, callback) {
    if (key in params && params[key] && params[key].length && params[key].length >= 2) {
        callback(params[key][0], params[key][1]); }
},
_iterateVParam: function(params, key, vCallback) {
    if (key in params && params[key] && params[key].length && params[key].length >= 1) {
        for (var i = 0; i < params[key].length; i = i + 1) {
            vCallback(params[key][i]); } }
},
_iterateKvParam: function(params, key, kvCallback) {
    if (key in params && params[key] && params[key].length && params[key].length >= 2) {
        for (var i = 0; i < params[key].length; i = i + 2) {
            kvCallback(params[key][i], params[key][i + 1]); } }
},
_iterateNkvParam: function(params, key, nkvCallback) {
    if (key in params && params[key] && params[key].length && params[key].length >= 3) {
        for (var i = 0; i < params[key].length; i = i + 3) {
            nkvCallback(params[key][i], params[key][i + 1], params[key][i + 2]); } }
},
_boolFirstParam: function(params, key, boolCallback) {
    TestLibrary._firstParam(params, key, function(value) {
        if (value  === "true") { boolCallback(true); }
        if (value  === "false") { boolCallback(false); } });
},
_trueFirstParam: function(params, key, voidCallback) {
    TestLibrary._boolFirstParam(params, key, function(boolValue) {
        if (boolValue) { voidCallback(); } });
},
TORMV: function() {
    TestLibrary._postMessage("TORMV");
},
callback_TORMV: function(data) {
    TestLibrary._postMessage("jsFail", {
        _message: "callback_TORMV called",
        _data: data,
        _dataType: typeof data
    });
},
callback_saveArrayOfCommands: function(arrayOfCommandsJsonString) {
    if (! TestLibrary._adjustCommandExecutor) {
        TestLibrary._postMessage("jsFail", {
            _message: "adjust command executor not present when save arrayOfCommands",
            _arrayOfCommandsJsonString: arrayOfCommandsJsonString,
            _arrayOfCommandsJsonStringType: typeof arrayOfCommandsJsonString
        });
        return;
    }

    TestLibrary._arrayOfCommands = JSON.parse(arrayOfCommandsJsonString);
    TestLibrary._cachePreviousPosition = -1;

    if (! TestLibrary._arrayOfCommands) {
        TestLibrary._postMessage("jsFail", {
            _message: "arrayOfCommands could not be parsed from json string",
            _arrayOfCommandsJsonString: arrayOfCommandsJsonString,
            _arrayOfCommandsJsonStringType: typeof arrayOfCommandsJsonString
        });
        return;
    }
},
callback_execCommandInPosition: function(commandPosition) {
    if (! TestLibrary._adjustCommandExecutor) {
        TestLibrary._postMessage("jsFail", {
            _message: "adjust command executor not present to execute command",
            _commandPosition: commandPosition,
            _commandPositionType: typeof commandPosition,
            _cachePreviousPosition: TestLibrary._cachePreviousPosition
        });
        return;
    }

    if (! TestLibrary._arrayOfCommands) {
        TestLibrary._postMessage("jsFail", {
            _message: "arrayOfCommands not present when expecting to excute command",
            _commandPosition: commandPosition,
            _commandPositionType: typeof commandPosition,
            _cachePreviousPosition: TestLibrary._cachePreviousPosition
        });
        return;
    }
    if (TestLibrary._cachePreviousPosition >= commandPosition) {
        TestLibrary._postMessage("jsFail", {
            _message: "received command position is equal or less than previous one",
            _commandPosition: commandPosition,
            _commandPositionType: typeof commandPosition,
            _cachePreviousPosition: TestLibrary._cachePreviousPosition
        });
        return;
    }

    TestLibrary._cachePreviousPosition = commandPosition;

    if (commandPosition >= TestLibrary._arrayOfCommands.length) {
        TestLibrary._postMessage("jsFail", {
            _message: "received command position is equal or more than array of commands length",
            _commandPosition: commandPosition,
            _commandPositionType: typeof commandPosition,
            _arrayOfCommandsLength: TestLibrary._arrayOfCommands.length,
            _arrayOfCommandsLengthType: typeof TestLibrary._arrayOfCommands.length
        });
        return;
    }

    const command = TestLibrary._arrayOfCommands.at(commandPosition);
    if (! command.className) {
        TestLibrary._postMessage("jsFail", {
            _message: "command does not contain class name",
            _commandPosition: commandPosition,
            _commandPositionType: typeof commandPosition,
            _command: command
        });
        return;
    }
    if (! command.functionName) {
        TestLibrary._postMessage("jsFail", {
            _message: "command does not contain function name",
            _commandPosition: commandPosition,
            _commandPositionType: typeof commandPosition,
            _command: command
        });
        return;
    }

    if (command.className == "TestOptions") {
        if (command.functionName == "teardown") {
            Adjust._teardown();
            TestLibrary._postMessage("teardown", {
                _testOptionsParameters: JSON.stringify(command.params),
                _testOptionsParametersType: typeof command.params
            });
        } else {
            TestLibrary._postMessage("jsFail", {
                _message: "TestOptions only valid function is teardown",
                _commandPosition: commandPosition,
                _commandPositionType: typeof commandPosition,
                _command: command
            });
        }
        return;
    }

    if (command.className == "AdjustV4") {
        TestLibrary._postMessage("jsFail", {
            _message: "Adjust v4 is not supported in test library bridge",
            _commandPosition: commandPosition,
            _commandPositionType: typeof commandPosition,
            _command: command
        });
        return;
    }

    const executorFunction = TestLibrary._adjustCommandExecutor[command.functionName];
    if (! executorFunction) {
        TestLibrary._postMessage("jsFail", {
            _message: "Adjust command executor does not contain function with the corresponding name",
            _commandPosition: commandPosition,
            _commandPositionType: typeof commandPosition,
            _command: command
        });
        return;
    }

    TestLibrary._postMessage("TORMV called", {
        _command: command
    });

    executorFunction(command.params);
}

};

function AdjustCommandExecutor() { };

AdjustCommandExecutor.prototype.start = function(params) {
    const appToken = TestLibrary._getFirstParam(params, "appToken");
    const environment = TestLibrary._getFirstParam(params, "environment");

    const adjustConfig = new AdjustConfig(appToken, environment);
    adjustConfig.doLogAll();

    TestLibrary._firstParam(params, "defaultTracker", function(defaultTracker) {
        adjustConfig.setDefaultTracker(defaultTracker); });

    TestLibrary._trueFirstParam(params, "sendInBackground", function() {
        adjustConfig.allowSendingFromBackground(); });

    TestLibrary._firstParam(params, "configureEventDeduplication", function(maxCapacity) {
        adjustConfig.setEventIdDeduplicationMaxCapacity(parseInt(maxCapacity)); });

    if ("customEndpointUrl" in params
        || "customEndpointPublicKeyHash" in params
        || "testServerBaseUrlEndpointUrl" in params)
    {
        const customEndpointPublicKeyHash =
            TestLibrary._getFirstParam(params, "customEndpointPublicKeyHash");

        let customEndpointUrl = null;
        if ("testServerBaseUrlEndpointUrl" in params) {
            customEndpointUrl = "127.0.0.1";
        } else {
            customEndpointUrl = TestLibrary._getFirstParam(params, "customEndpointUrl");
        }

        adjustConfig.setCustomEndpoint(customEndpointUrl, customEndpointPublicKeyHash);
    }

    if ("attributionCallbackSendAll" in params) {
        adjustConfig.setAdjustAttributionSubscriber(function(methodName, attribution) {
            TestLibrary.addInfoToSend("tracker_token", attribution.trackerToken);
            TestLibrary.addInfoToSend("tracker_name", attribution.trackerName);
            TestLibrary.addInfoToSend("network", attribution.network);
            TestLibrary.addInfoToSend("campaign", attribution.campaign);
            TestLibrary.addInfoToSend("adgroup", attribution.adgroup);
            TestLibrary.addInfoToSend("creative", attribution.creative);
            TestLibrary.addInfoToSend("click_label", attribution.clickLabel);
            TestLibrary.addInfoToSend("adid", attribution.adid);
            TestLibrary.addInfoToSend("deeplink", attribution.deeplink);
            TestLibrary.addInfoToSend("state", attribution.state);
            TestLibrary.addInfoToSend("cost_type", attribution.costType);
            if (attribution.costAmount !== undefined && attribution.costAmount !== null) {
                TestLibrary.addInfoToSend("cost_amount", attribution.costAmount.toString());
            }
            TestLibrary.addInfoToSend("cost_currency", attribution.costCurrency);

            TestLibrary.sendInfoToServer();
        });
    }

    TestLibrary._adjustDefaultInstance().initSdk(adjustConfig);
}
AdjustCommandExecutor.prototype.trackEvent = function(params) {
    const eventToken = TestLibrary._getFirstParam(params, "eventToken");

    const adjustEvent = new AdjustEvent(eventToken);

    TestLibrary._firstTwoParam(params, "currencyAndRevenue", function(currency, revenueString){
        adjustEvent.setRevenueDouble(parseFloat(revenueString), currency); });

    TestLibrary._iterateKvParam(params, "callbackParams", function(key, value){
        adjustEvent.addCallbackParameter(key, value); });

    TestLibrary._iterateKvParam(params, "partnerParams", function(key, value){
        adjustEvent.addPartnerParameter(key, value); });

    TestLibrary._firstParam(params, "deduplicationId", function(deduplicationId){
        adjustEvent.setDeduplicationId(deduplicationId); });

    TestLibrary._adjustDefaultInstance().trackEvent(adjustEvent);
}
AdjustCommandExecutor.prototype.stop = function() {
    TestLibrary._adjustDefaultInstance().inactivateSdk();
}
AdjustCommandExecutor.prototype.restart = function() {
    TestLibrary._adjustDefaultInstance().reactivateSdk();
}
AdjustCommandExecutor.prototype.setOfflineMode = function(params) {
    TestLibrary._boolFirstParam(params, "enabled", function(isEnabled){
        isEnabled ? TestLibrary._adjustDefaultInstance().switchToOfflineMode()
            : TestLibrary._adjustDefaultInstance().switchBackToOnlineMode(); });
}
AdjustCommandExecutor.prototype.addGlobalCallbackParameter = function(params) {
    TestLibrary._iterateKvParam(params, "keyValuePairs", function(key, value){
        TestLibrary._adjustDefaultInstance().addGlobalCallbackParameter(key, value); });
}
AdjustCommandExecutor.prototype.addGlobalPartnerParameter = function(params) {
    TestLibrary._iterateKvParam(params, "keyValuePairs", function(key, value){
        TestLibrary._adjustDefaultInstance().addGlobalPartnerParameter(key, value); });
}
AdjustCommandExecutor.prototype.removeGlobalCallbackParameter = function(params) {
    TestLibrary._iterateVParam(params, "key", function(value){
        TestLibrary._adjustDefaultInstance().removeGlobalCallbackParameter(value); });
}
AdjustCommandExecutor.prototype.removeGlobalPartnerParameter = function(params) {
    TestLibrary._iterateVParam(params, "key", function(value){
        TestLibrary._adjustDefaultInstance().removeGlobalPartnerParameter(value); });
}
AdjustCommandExecutor.prototype.clearGlobalCallbackParameters = function(params) {
    TestLibrary._adjustDefaultInstance().clearGlobalCallbackParameters();
}
AdjustCommandExecutor.prototype.clearGlobalPartnerParameters = function(params) {
    TestLibrary._adjustDefaultInstance().clearGlobalPartnerParameters();
}
AdjustCommandExecutor.prototype.setPushToken = function(params) {
    const pushToken = TestLibrary._getFirstParam(params, "pushToken");
    TestLibrary._adjustDefaultInstance().trackPushToken(pushToken);
}
AdjustCommandExecutor.prototype.openDeeplink = function(params) {
    const deeplink = TestLibrary._getFirstParam(params, "deeplink");
    TestLibrary._adjustDefaultInstance().trackLaunchedDeeplink(deeplink);
}
AdjustCommandExecutor.prototype.gdprForgetMe = function(params) {
    TestLibrary._adjustDefaultInstance().gdprForgetDevice();
}
AdjustCommandExecutor.prototype.trackAdRevenue = function(params) {
    const adRevenueSource = TestLibrary._getFirstParam(params, "adRevenueSource");

    const adjustAdRevenue = new AdjustAdRevenue(adRevenueSource);

    TestLibrary._firstTwoParam(params, "currencyAndRevenue", function(currency, revenueString){
        adjustAdRevenue.setRevenueDouble(parseFloat(revenueString), currency);});

    TestLibrary._firstParam(params, "adImpressionsCount", function(adImpressionsCount){
        adjustAdRevenue.setAdImpressionsCount(parseInt(adImpressionsCount));});

    TestLibrary._firstParam(params, "adRevenueNetwork", function(adRevenueNetwork){
        adjustAdRevenue.setNetwork(adRevenueNetwork);});

    TestLibrary._firstParam(params, "adRevenueUnit", function(adRevenueUnit){
        adjustAdRevenue.setUnit(adRevenueUnit);});

    TestLibrary._firstParam(params, "adRevenuePlacement", function(adRevenuePlacement){
        adjustAdRevenue.setPlacement(adRevenuePlacement);});

    TestLibrary._iterateKvParam(params, "callbackParams", function(key, value){
        adjustAdRevenue.addCallbackParameter(key, value);});

    TestLibrary._iterateKvParam(params, "partnerParams", function(key, value){
        adjustAdRevenue.addPartnerParameter(key, value);});

    TestLibrary._firstParam(params, "deduplicationId", function(deduplicationId){
        adjustAdRevenue.setDeduplicationId(deduplicationId);});

    TestLibrary._adjustDefaultInstance().trackAdRevenue(adjustAdRevenue);
}
AdjustCommandExecutor.prototype.resume = function(params) {
    TestLibrary._adjustDefaultInstance().appWentToTheForegroundManualCall();
}
AdjustCommandExecutor.prototype.pause = function(params) {
    TestLibrary._adjustDefaultInstance().appWentToTheBackgroundManualCall();
}
AdjustCommandExecutor.prototype.thirdPartySharing = function(params) {
    const adjustThirdPartySharing = new AdjustThirdPartySharing();

    TestLibrary._boolFirstParam(params, "isEnabled", function(isEnabled){
        isEnabled ? adjustThirdPartySharing.enableThirdPartySharing()
            : adjustThirdPartySharing.disableThirdPartySharing();});

    TestLibrary._iterateNkvParam(params, "granularOptions", function(name, key, value){
        adjustThirdPartySharing.addGranularOption(name, key, value);});

    TestLibrary._iterateNkvParam(params, "partnerSharingSettings", function(name, key, value){
        let boolValue = null;
        if (value === "true") { boolValue = true; }
        if (value === "false") { boolValue = false; }
        adjustThirdPartySharing.addPartnerSharingSetting(name, key, boolValue);});

    TestLibrary._adjustDefaultInstance().trackThirdPartySharing(adjustThirdPartySharing);
}
AdjustCommandExecutor.prototype.measurementConsent = function(params) {
    TestLibrary._boolFirstParam(params, "isEnabled", function(isEnabled){
        isEnabled ? TestLibrary._adjustDefaultInstance().activateMeasurementConsent()
            : TestLibrary._adjustDefaultInstance().inactivateMeasurementConsent();});
}

/*

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
    Adjust.getSdkVersion();
},

getSdkVersion: function(sdkVersion) {
    const message = {
    action:'adjustTLB_startTestSession',
    data: sdkVersion
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
*/
