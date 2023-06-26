//
//  ATAAdjustCallbacks.h
//  AdjustTestApp
//
//  Created by Pedro Silva on 21.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATLTestLibrary.h"

#import "ADJAdjustLaunchedDeeplinkCallback.h"
#import "ADJAdjustAttributionSubscriber.h"

@interface ATAAdjustCallbacks : NSObject

+ (nonnull id<ADJAdjustLaunchedDeeplinkCallback>)
    adjustLaunchedDeeplinkGetterWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
    extraPath:(nonnull NSString *)extraPath;

+ (nonnull id<ADJAdjustAttributionSubscriber>)
    adjustAttributionSubscriberWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
    extraPath:(nonnull NSString *)extraPath;

+ (nonnull id<ADJAdjustAttributionSubscriber>)
    adjustAttributionDeferredDeeplinkSubscriberWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
    extraPath:(nonnull NSString *)extraPath;

@end

