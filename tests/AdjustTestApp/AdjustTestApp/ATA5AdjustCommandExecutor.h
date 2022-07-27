//
//  ATA5AdjustCommandExecutor.h
//  AdjustTestApp
//
//  Created by Pedro S. on 06.05.21.
//  Copyright © 2021 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATLTestLibrary.h"

@interface ATA5AdjustCommandExecutor : NSObject<AdjustCommandDictionaryParametersDelegate>

- (nonnull instancetype)initWithUrl:(nonnull NSString *)url
                        testLibrary:(nonnull ATLTestLibrary *)testLibrary;

@end
