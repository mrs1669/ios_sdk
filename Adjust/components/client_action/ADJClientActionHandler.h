//
//  ADJClientActionHandler.h
//  Adjust
//
//  Created by Genady Buchatsky on 29.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoData.h"
#import "ADJTimestampMilli.h"
#import "ADJSQLiteStorageActionBase.h"

@protocol ADJClientActionHandler <NSObject>

- (BOOL)ccCanHandlePreFirstSessionClientAction;

- (void)ccHandleClientActionWithIoInjectedData:(nonnull ADJIoData *)clientActionIoInjectedData
                                  apiTimestamp:(nonnull ADJTimestampMilli *)apiTimestamp
                           removeStorageAction:(nonnull ADJSQLiteStorageActionBase *)removeStorageAction;

@end
