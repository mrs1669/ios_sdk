//
//  ADJClientReturnExecutor.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

@protocol ADJClientReturnExecutor <NSObject>

- (void)executeClientReturnWithBlock:(nonnull void (^)(void))blockToExecute;

@end
