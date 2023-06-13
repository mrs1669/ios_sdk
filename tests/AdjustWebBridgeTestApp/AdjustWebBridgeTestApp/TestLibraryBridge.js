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
