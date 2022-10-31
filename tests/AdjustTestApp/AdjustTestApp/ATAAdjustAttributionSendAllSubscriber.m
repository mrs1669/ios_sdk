//
//  ATAAdjustAttributionSendAllSubscriber.m
//  AdjustTestApp
//
//  Created by Pedro Silva on 28.07.22.
//

#import "ATAAdjustAttributionSendAllSubscriber.h"
#import "ADJAdjustAttribution.h"

@interface ATAAdjustAttributionSendAllSubscriber ()

@property (nullable, readonly, weak, nonatomic) ATLTestLibrary *testLibraryWeak;
@property (nonnull, readonly, strong, nonatomic) NSString *extraPath;

@end

@implementation ATAAdjustAttributionSendAllSubscriber
#pragma mark Instantiation
- (nonnull instancetype)initWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
                                  extraPath:(nonnull NSString *)extraPath
{
    self = [super init];

    _testLibraryWeak = testLibrary;
    _extraPath = extraPath;

    return self;
}


#pragma mark Public API
#pragma mark - ADJAdjustAttributionSubscriber

#define addWhenValid(key,valueName)                                             \
if (adjustAttribution.valueName.length > 0) {                               \
[testLibrary addInfoToSend:@#key value:adjustAttribution.valueName];    \
}

- (void)didChangeWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    [self logDebug:@"did change attribution: %@", adjustAttribution];

    ATLTestLibrary *_Nullable testLibrary = self.testLibraryWeak;
    if (testLibrary == nil) {
        [self logError:@"Cannot send attribution change info without reference to test library"];
        return;
    }

    addWhenValid(tracker_token, trackerToken)
    addWhenValid(tracker_name, trackerName)
    addWhenValid(network, network)
    addWhenValid(campaign, campaign)
    addWhenValid(adgroup, adgroup)
    addWhenValid(creative, creative)
    addWhenValid(click_label, clickLabel)
    // TODO: to be cleaned up when adid gets removed from ADJAdjustAttribution
    // keeping the comment here until that change is officially done
    // addWhenValid(adid, adid)
    addWhenValid(deeplink, deeplink)
    addWhenValid(state, state)
    addWhenValid(cost_type, costType)

    if (adjustAttribution.costAmount >= 0) {
        [testLibrary addInfoToSend:@"cost_amount"
                             value:@(adjustAttribution.costAmount).description];
    }
    addWhenValid(cost_currency, costCurrency)

    [testLibrary sendInfoToServer:self.extraPath];
}

- (void)didReadWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    [self logDebug:@"did read attribution: %@", adjustAttribution];
}

#pragma mark Internal Methods
- (void)logDebug:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);
    NSString *logMessage = [[NSString alloc] initWithFormat:message arguments:parameters];
    va_end(parameters);

    NSLog(@"\t[ATAAdjustAttributionSendAllSubscriber][Debug] %@", logMessage);
}

- (void)logError:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);
    NSString *logMessage = [[NSString alloc] initWithFormat:message arguments:parameters];
    va_end(parameters);

    NSLog(@"\t[ATAAdjustAttributionSendAllSubscriber][Error] %@", logMessage);
}

@end
