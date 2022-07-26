//
//  ADJSQLiteStorage.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSQLiteDb.h"
#import "ADJV4FilesData.h"
#import "ADJV4UserDefaultsData.h"

@protocol ADJSQLiteStorage <NSObject>

// - implemented by base class
- (void)readIntoMemorySync:(nonnull ADJSQLiteDb *)sqliteDb;
- (nonnull NSString *)sqlStringForOnCreate;

// - implemented by final class
- (nullable NSString *)sqlStringForOnUpgrade:(int)oldVersion;

- (void)migrateFromV4WithV4FilesData:(nonnull ADJV4FilesData *)v4FilesData
                  v4UserDefaultsData:(nonnull ADJV4UserDefaultsData *)v4UserDefaultsData;

@end
