//
//  ADJSQLiteDatabaseProvider.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteDb.h"

@protocol ADJSQLiteDatabaseProvider <NSObject>

- (nonnull ADJSQLiteDb *)sqliteDb;

@end
