//
//  ATA5AdjustAttributionDeferredDeeplinkSubscriber.m
//  AdjustTestApp
//
//  Created by Pedro S. on 17.05.21.
//  Copyright © 2021 adjust. All rights reserved.
//

#import "ATA5AdjustAttributionDeferredDeeplinkSubscriber.h"

@interface ATA5AdjustAttributionDeferredDeeplinkSubscriber ()

@property (nullable, readonly, weak, nonatomic) ATLTestLibrary *testLibraryWeak;
@property (nonnull, readonly, strong, nonatomic) NSString *extraPath;

@end

@implementation ATA5AdjustAttributionDeferredDeeplinkSubscriber
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
#pragma mark - ADJ5AdjustAttributionSubscriber

- (void)didChangeWithAdjustAttribution:(nonnull ADJ5AdjustAttribution *)adjustAttribution {
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

- (void)didReadWithAdjustAttribution:(nonnull ADJ5AdjustAttribution *)adjustAttribution {
    [self logDebug:@"did read attribution: %@", adjustAttribution];
}

#pragma mark Internal Methods

- (void)logDebug:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);
    NSString *logMessage = [[NSString alloc] initWithFormat:message arguments:parameters];
    va_end(parameters);

    NSLog(@"\t[ATA5AdjustAttributionDeferredDeeplinkSubscriber][Debug] %@", logMessage);
}
- (void)logError:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);
    NSString *logMessage = [[NSString alloc] initWithFormat:message arguments:parameters];
    va_end(parameters);

    NSLog(@"\t[ATA5AdjustAttributionDeferredDeeplinkSubscriber][Error] %@", logMessage);
}

@end
