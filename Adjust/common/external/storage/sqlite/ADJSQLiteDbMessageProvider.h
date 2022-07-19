//
//  ADJSQLiteDbMessageProvider.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "ADJSQLiteStatement.h"
@class ADJSQLiteStatement;

@protocol ADJSQLiteDbMessageProvider <NSObject>

- (nonnull NSString *)lastErrorMessage;

- (void)statementClosed:(nonnull ADJSQLiteStatement *)statement;

@end
