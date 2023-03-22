//
//  ADJClientActionPostSdkStart.h
//  Adjust
//
//  Created by Genady Buchatsky on 13.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJClientActionsAPI.h"
#import "ADJClientActionHandler.h"
#import "ADJNonEmptyString.h"

@protocol ADJClientActionsAPIPostSdkStart <ADJClientActionsAPI>
- (nullable id<ADJClientActionHandler>)ccHandlerById:(nonnull ADJNonEmptyString *)clientHandlerId;
@end
