//
//  ADJSQLiteStatement.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSQLiteStatement.h"

#import "ADJSQLiteDb.h"
#import "ADJUtilF.h"

#pragma mark Fields

@interface ADJSQLiteStatement ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) NSString *sqlString;
@property (nullable, readonly, weak, nonatomic)
id<ADJSQLiteDbMessageProvider> sqliteDbMessageProviderWeak;

#pragma mark - Internal variables
@property (nonatomic, readwrite, assign) BOOL hasClosed;

@end

@implementation ADJSQLiteStatement {
#pragma mark - Unmanaged variables
    sqlite3_stmt *_sqlite3_stmt;
}
#pragma mark Instantiation
- (nonnull instancetype)initWithSqliteStatement:(nonnull sqlite3_stmt *)sqliteStatement
                                      sqlString:(nonnull NSString *)sqlString
                         sqliteDbMessageProvider:(nonnull id<ADJSQLiteDbMessageProvider>)sqliteDbMessageProvider {
    self = [super init];
    _sqlite3_stmt = sqliteStatement;
    _sqlString = sqlString;
    _sqliteDbMessageProviderWeak = sqliteDbMessageProvider;
    
    _hasClosed = NO;
    
    return self;
}

#pragma mark Public API
- (void)resetStatement {
    if (_sqlite3_stmt) {
        sqlite3_reset(_sqlite3_stmt);
    }
}

- (void)closeStatement {
    if (self.hasClosed) {
        return;
    }
    self.hasClosed = YES;
    
    if (_sqlite3_stmt) {
        sqlite3_finalize(_sqlite3_stmt);
        _sqlite3_stmt = NULL;
    }
    
    id<ADJSQLiteDbMessageProvider> _Nullable sqliteDbMessageProvider =
    self.sqliteDbMessageProviderWeak;
    
    if (sqliteDbMessageProvider == nil) {
        return;
    }
    
    [sqliteDbMessageProvider statementClosed:self];
}

// adapted from https://github.com/ccgus/fmdb/blob/2.7.4/src/fmdb/FMResultSet.m#L163
- (BOOL)nextInQueryStatementWithLogger:(nonnull ADJLogger *)logger {
    if (! _sqlite3_stmt) {
        [logger debugDev:@"Cannot get next in query statement from closed statement"
               issueType:ADJIssueStorageIo];
        return NO;
    }
    
    int returnCode = sqlite3_step(_sqlite3_stmt);
    
    if (SQLITE_DONE == returnCode || SQLITE_ROW == returnCode) {
        // no error
    } else {
        if (SQLITE_BUSY == returnCode || SQLITE_LOCKED == returnCode) {
            [self logSteppingErrorWithReturnCode:returnCode
                                          logger:logger
                               reasonDescription:@"Database busy"
                             isQueryOrElseUpdate:YES];
        } else if (SQLITE_ERROR == returnCode) {
            [self logSteppingErrorWithReturnCode:returnCode
                                          logger:logger
                               reasonDescription:@"Error"
                             isQueryOrElseUpdate:YES];
        } else if (SQLITE_MISUSE == returnCode) {
            [self logSteppingErrorWithReturnCode:returnCode
                                          logger:logger
                               reasonDescription:@"Misuse"
                             isQueryOrElseUpdate:YES];
        } else {
            [self logSteppingErrorWithReturnCode:returnCode
                                          logger:logger
                               reasonDescription:@"Unknown"
                             isQueryOrElseUpdate:YES];
        }
    }
    
    if (SQLITE_ROW != returnCode) {
        //[self closeStatement]; // TODO check if it can be auto closed
        return NO;
    } else {
        return YES;
    }
}

// adapted from https://github.com/ccgus/fmdb/blob/2.7.4/src/fmdb/FMDatabase.m#L963
- (BOOL)executeUpdatePreparedStatementWithLogger:(nonnull ADJLogger *)logger {
    if (! _sqlite3_stmt) {
        [logger debugDev:@"Cannot update in statement from closed statement"
               issueType:ADJIssueStorageIo];
        return NO;
    }
    
    /* Call sqlite3_step() to run the virtual machine. Since the SQL being
     ** executed is not a SELECT statement, we assume no data will be returned.
     */
    int returnCode = sqlite3_step(_sqlite3_stmt);
    
    if (SQLITE_DONE == returnCode) {
        // all is well, let's return.
    } else if (SQLITE_ROW == returnCode) {
        [logger debugDev:@"Query executed as an update"
                     key:@"sql"
                   value:self.sqlString
               issueType:ADJIssueStorageIo];
    } else {
        if (SQLITE_INTERRUPT == returnCode) {
            [self logSteppingErrorWithReturnCode:returnCode
                                          logger:logger
                               reasonDescription:@"Interrupted"
                             isQueryOrElseUpdate:NO];
        } else if (SQLITE_ERROR == returnCode) {
            [self logSteppingErrorWithReturnCode:returnCode
                                          logger:logger
                               reasonDescription:@"Error"
                             isQueryOrElseUpdate:NO];
        }
        else if (SQLITE_MISUSE == returnCode) {
            [self logSteppingErrorWithReturnCode:returnCode
                                          logger:logger
                               reasonDescription:@"Misuse"
                             isQueryOrElseUpdate:NO];
        } else {
            [self logSteppingErrorWithReturnCode:returnCode
                                          logger:logger
                               reasonDescription:@"Unknown"
                             isQueryOrElseUpdate:NO];
        }
    }
    
    /* Finalize the virtual machine. This releases all memory and other
     ** resources allocated by the sqlite3_prepare() call above.
     */
    /*
     int closeErrorCode = sqlite3_finalize(statement);
     
     if (SQLITE_OK != closeErrorCode) {
     [logger error:@"Finalizing update: %@, with code: %d and message: %@",
     sqlUpdateString, closeErrorCode, [self lastErrorMessage]];
     }
     */
    return (returnCode == SQLITE_DONE || returnCode == SQLITE_OK);
}

- (BOOL)validStringForColumnIndex:(int)columnIndex {
    if (! _sqlite3_stmt) {
        return NO;
    }
    
    return sqlite3_column_type(_sqlite3_stmt, columnIndex) == SQLITE_TEXT
    && columnIndex < sqlite3_column_count(_sqlite3_stmt);
    
}
- (nullable NSString *)validatedStringForColumnIndex:(int)columnIndex{
    if (! _sqlite3_stmt) {
        return nil;
    }
    
    const unsigned char *_Nullable cString = sqlite3_column_text(_sqlite3_stmt, columnIndex);
    
    if (cString) {
        return [NSString stringWithUTF8String:(const char *)cString];
    } else {
        return nil;
    }
}

- (nullable NSString *)stringForColumnIndex:(int)columnIndex {
    if (! [self validStringForColumnIndex:columnIndex]) {
        return nil;
    }
    
    return [self validatedStringForColumnIndex:columnIndex];
}

- (BOOL)validIntForColumnIndex:(int)columnIndex {
    if (! _sqlite3_stmt) {
        return NO;
    }
    
    return sqlite3_column_type(_sqlite3_stmt, columnIndex) == SQLITE_INTEGER
    && columnIndex < sqlite3_column_count(_sqlite3_stmt);
    
}

- (nullable NSNumber *)numberIntForColumnIndex:(int)columnIndex {
    if (![self validIntForColumnIndex:columnIndex]) {
        return nil;
    }
    
    return [NSNumber numberWithInt:sqlite3_column_int(_sqlite3_stmt, columnIndex)];
}

- (void)bindString:(nonnull NSString *)stringValue columnIndex:(int)columnIndex {
    if (! _sqlite3_stmt) {
        return;
    }
    
    sqlite3_bind_text(_sqlite3_stmt, columnIndex, stringValue.UTF8String, -1, SQLITE_STATIC);
}

- (void)bindInt:(int)intValue columnIndex:(int)columnIndex {
    if (! _sqlite3_stmt) {
        return;
    }
    
    sqlite3_bind_int(_sqlite3_stmt, columnIndex, intValue);
}

#pragma mark - NSObject
- (void)dealloc {
    [self closeStatement];
}

#pragma mark Internal Methods
- (void)logSteppingErrorWithReturnCode:(int)returnCode
                                logger:(nonnull ADJLogger *)logger
                     reasonDescription:(nonnull NSString *)reasonDescription
                   isQueryOrElseUpdate:(BOOL)isQueryOrElseUpdate
{
    [logger debugDevStart:@"Error stepping"]
        .wKv(@"reason", reasonDescription)
        .wKv(@"isQueryOrElseUpdate", isQueryOrElseUpdate ? @"true" : @"false")
        .wKv(@"sql", self.sqlString)
        .wKv(@"returnCode", [ADJUtilF intFormat:returnCode])
        .wKv(@"lastErrorMessage@", [self lastErrorMessage])
        .wIssue(ADJIssueStorageIo)
        .end();
}

- (nonnull NSString *)lastErrorMessage {
    id<ADJSQLiteDbMessageProvider> _Nullable sqliteDbMessageProvider =
    self.sqliteDbMessageProviderWeak;
    
    if (sqliteDbMessageProvider == nil) {
        return @"Without reference to SQLiteDb";
    }
    
    return [sqliteDbMessageProvider lastErrorMessage];
}

@end
