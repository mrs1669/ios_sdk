//
//  ADJSQLiteStatement.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

#import "ADJSQLiteDbMessageProvider.h"
#import "ADJLogger.h"

@interface ADJSQLiteStatement : NSObject
// instantiation
- (nonnull instancetype)
    initWithSqliteStatement:(nonnull sqlite3_stmt *)sqliteStatement
    sqlString:(nonnull NSString *)sqlString
    sqiteDbMessageProvider:(nonnull id<ADJSQLiteDbMessageProvider>)sqiteDbMessageProvider;

// public api
- (void)resetStatement;
- (void)closeStatement;

- (BOOL)nextInQueryStatementWithLogger:(nonnull ADJLogger *)logger;
- (BOOL)executeUpdatePreparedStatementWithLogger:(nonnull ADJLogger *)logger;

- (BOOL)validStringForColumnIndex:(int)columnIndex;
- (nullable NSString *)validatedStringForColumnIndex:(int)columnIndex;
- (nullable NSString *)stringForColumnIndex:(int)columnIndex;

- (BOOL)validIntForColumnIndex:(int)columnIndex;
- (nullable NSNumber *)numberIntForColumnIndex:(int)columnIndex;

- (void)bindString:(nonnull NSString *)stringValue
       columnIndex:(int)columnIndex;

- (void)bindInt:(int)intValue
    columnIndex:(int)columnIndex;

@end
