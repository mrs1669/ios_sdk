//
//  ATAAdjustAttributionDeferredDeeplinkSubscriber.m
//  AdjustTestApp
//
//  Created by Pedro Silva on 28.07.22.
//

#import "ATAAdjustAttributionDeferredDeeplinkSubscriber.h"

@interface ATAAdjustAttributionDeferredDeeplinkSubscriber ()

@property (nullable, readonly, weak, nonatomic) ATLTestLibrary *testLibraryWeak;
@property (nonnull, readonly, strong, nonatomic) NSString *extraPath;

@end

@implementation ATAAdjustAttributionDeferredDeeplinkSubscriber
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

- (void)didChangeWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    [self logDebug:@"did change attribution: %@", adjustAttribution];

    ATLTestLibrary *_Nullable testLibrary = self.testLibraryWeak;
    if (testLibrary == nil) {
        [self logError:@"Cannot send attribution change info without reference to test library"];
        return;
    }

    if (adjustAttribution.deeplink == nil) {
        [self logError:@"Deeplink in attribution null"];
        return;
    }

    [testLibrary addInfoToSend:@"deeplink" value:adjustAttribution.deeplink];
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

    NSLog(@"\t[ATAAdjustAttributionDeferredDeeplinkSubscriber][Debug] %@", logMessage);
}

- (void)logError:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);
    NSString *logMessage = [[NSString alloc] initWithFormat:message arguments:parameters];
    va_end(parameters);

    NSLog(@"\t[ATAAdjustAttributionDeferredDeeplinkSubscriber][Error] %@", logMessage);
}

@end
