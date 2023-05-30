//
//  ATAAdjustDeeplinkCallback.m
//  AdjustTestApp
//
//  Created by Aditi Agrawal on 26/04/23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ATAAdjustLaunchedDeeplinkCallback.h"

@interface ATAAdjustLaunchedDeeplinkCallback ()

@property (nullable, readonly, weak, nonatomic) ATLTestLibrary *testLibraryWeak;
@property (nonnull, readonly, strong, nonatomic) NSString *extraPath;

@end

@implementation ATAAdjustLaunchedDeeplinkCallback
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
#pragma mark - ADJAdjustLaunchedDeeplinkCallback

- (void)didReadWithAdjustLaunchedDeeplink:(nonnull NSString *)adjustLaunchedDeeplink {
    [self.testLibraryWeak addInfoToSend:@"last_deeplink" value:adjustLaunchedDeeplink.description];
    [self.testLibraryWeak sendInfoToServer:self.extraPath];
}

- (void)didFailWithAdjustCallbackMessage:(NSString *)message {
    [self.testLibraryWeak addInfoToSend:@"last_deeplink" value:@""];
    [self.testLibraryWeak sendInfoToServer:self.extraPath];
}

@end

