//
//  ATAAdjustAttributionDeferredDeeplinkSubscriber.h
//  AdjustTestApp
//
//  Created by Pedro Silva on 28.07.22.
//

#import <Foundation/Foundation.h>

#import "ADJAdjustAttributionSubscriber.h"
#import "ATLTestLibrary.h"

@interface ATAAdjustAttributionDeferredDeeplinkSubscriber : NSObject<ADJAdjustAttributionSubscriber>

- (nonnull instancetype)initWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
                                  extraPath:(nonnull NSString *)extraPath;

@end
