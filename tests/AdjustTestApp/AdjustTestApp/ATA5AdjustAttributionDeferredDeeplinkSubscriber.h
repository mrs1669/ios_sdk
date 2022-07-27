//
//  ATA5AdjustAttributionDeferredDeeplinkSubscriber.h
//  AdjustTestApp
//
//  Created by Pedro S. on 17.05.21.
//  Copyright © 2021 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJ5AdjustAttributionSubscriber.h"
#import "ATLTestLibrary.h"

@interface ATA5AdjustAttributionDeferredDeeplinkSubscriber :
    NSObject<ADJ5AdjustAttributionSubscriber>

- (nonnull instancetype)initWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
                                  extraPath:(nonnull NSString *)extraPath;

@end
