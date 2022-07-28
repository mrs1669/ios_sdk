//
//  ATAAdjustCommandExecutor.h
//  AdjustTestApp
//
//  Created by Pedro Silva on 28.07.22.
//

#import <Foundation/Foundation.h>

#import "ATLTestLibrary.h"

@interface ATAAdjustCommandExecutor : NSObject<AdjustCommandDictionaryParametersDelegate>

- (nonnull instancetype)initWithUrl:(nonnull NSString *)url
                        testLibrary:(nonnull ATLTestLibrary *)testLibrary;

@end
